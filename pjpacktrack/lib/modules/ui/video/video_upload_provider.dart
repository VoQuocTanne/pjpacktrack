import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pjpacktrack/modules/ui/video/video_repo/video_upload_state.dart';

final videoUploadProvider = StateNotifierProvider.autoDispose<VideoUploadNotifier, VideoUploadState>((ref) {
  return VideoUploadNotifier();
});

class VideoUploadNotifier extends StateNotifier<VideoUploadState> {
  VideoUploadNotifier() : super(const VideoUploadState());

  Future<void> uploadVideo({
    required String filePath,
    required AwsCredentialsConfig credentialsConfig,
    required String lastScannedCode,
    required String selectedDeliveryOption,
    required bool isQRCode,
    required String storeId,
  }) async {
    try {
      state = state.copyWith(isUploading: true, message: 'Đang tải video lên AWS...');
      final uploadData = await _prepareVideoUpload(
        filePath: filePath,
        credentialsConfig: credentialsConfig,
        lastScannedCode: lastScannedCode,
        selectedDeliveryOption: selectedDeliveryOption,
      );
      await _handleFirestoreUpload(
        uploadData: [uploadData],
        isQRCode: isQRCode,
        storeId: storeId,
      );
      state = state.copyWith(
        isUploading: false,
        message: 'Video đã được cập nhật cho đơn hàng',
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Lỗi trong quá trình xử lý: $e',
      );
    }
  }

  Future<void> uploadMultipleVideos({
    required List<String> filePaths,
    required AwsCredentialsConfig credentialsConfig,
    required String lastScannedCode,
    required String selectedDeliveryOption,
    required bool isQRCode,
    required String storeId,
  }) async {
    try {
      state = state.copyWith(isUploading: true, message: 'Đang tải videos lên AWS...');
      final uploadResults = await Future.wait(
        filePaths.map((path) => _prepareVideoUpload(
          filePath: path,
          credentialsConfig: credentialsConfig,
          lastScannedCode: lastScannedCode,
          selectedDeliveryOption: selectedDeliveryOption,
        )),
      );
      await _handleFirestoreUpload(
        uploadData: uploadResults,
        isQRCode: isQRCode,
        storeId: storeId,
      );
      state = state.copyWith(
        isUploading: false,
        message: 'Tất cả videos đã được cập nhật',
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Lỗi trong quá trình xử lý: $e',
      );
    }
  }

  Future<Map<String, dynamic>> _prepareVideoUpload({
    required String filePath,
    required AwsCredentialsConfig credentialsConfig,
    required String lastScannedCode,
    required String selectedDeliveryOption,
  }) async {
    final videoFileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(filePath)}';
    final videoKey = 'videos/$videoFileName';

    final uploadFile = await _uploadToAWS(filePath, videoKey, credentialsConfig);
    final videoUrl = _getVideoUrl(videoKey, credentialsConfig);
    uploadFile.dispose();

    return {
      'videoUrl': videoUrl,
      'videoFileName': videoFileName,
      'code': lastScannedCode,
      'deliveryOption': selectedDeliveryOption,
    };
  }

  Future<UploadFile> _uploadToAWS(
      String filePath,
      String videoKey,
      AwsCredentialsConfig credentialsConfig,
      ) async {
    final uploadConfig = UploadTaskConfig(
      credentailsConfig: credentialsConfig,
      url: videoKey,
      uploadType: UploadType.file,
      file: File(filePath),
    );

    final uploadFile = UploadFile(config: uploadConfig);
    uploadFile.uploadProgress.listen((event) {
      state = state.copyWith(
        uploadProgress: event[0] / event[1],
      );
    });

    await uploadFile.upload();
    return uploadFile;
  }

  String _getVideoUrl(String videoKey, AwsCredentialsConfig credentialsConfig) {
    return 'https://${credentialsConfig.bucketName}.s3.${credentialsConfig.region}.amazonaws.com/$videoKey';
  }

  Future<bool> _canUploadMore(String userId, int uploadCount) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return false;

    final data = userDoc.data()!;
    final quantity = data['quantity'] ?? 0;
    final rank = data['rank'] ?? 'free';
    final limit = rank == 'free' ? 50 : (data['limit'] ?? 50);

    return (quantity + uploadCount) <= limit;
  }

  Future<void> _incrementQuantity(String userId, int increment, WriteBatch batch) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    final currentQuantity = data['quantity'] ?? 0;
    final rank = data['rank'] ?? 'free';
    final limit = rank == 'free' ? 50 : (data['limit'] ?? 50);

    final newQuantity = currentQuantity + increment;
    if (newQuantity <= limit) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      batch.update(userRef, {'quantity': newQuantity});
    }
  }

  Future<void> _handleFirestoreUpload({
    required List<Map<String, dynamic>> uploadData,
    required bool isQRCode,
    required String storeId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      state = state.copyWith(error: 'Người dùng chưa đăng nhập');
      return;
    }

    if (!await _canUploadMore(currentUser.uid, uploadData.length)) {
      state = state.copyWith(error: 'Đã đạt giới hạn tải lên');
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final data in uploadData) {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .where('code', isEqualTo: data['code'])
          .get();

      final doc = orderSnapshot.docs.firstOrNull;

      if (doc != null) {
        await _handleExistingDocument(
          docRef: doc.reference,
          data: data,
          existingData: doc.data(),
          batch: batch,
        );
      } else {
        _createNewDocument(
          data: data,
          userId: currentUser.uid,
          isQRCode: isQRCode,
          storeId: storeId,
          batch: batch,
        );
      }
    }

    await _incrementQuantity(currentUser.uid, uploadData.length, batch);
    await batch.commit();
  }

  Future<void> _handleExistingDocument({
    required DocumentReference docRef,
    required Map<String, dynamic> data,
    required Map<String, dynamic> existingData,
    required WriteBatch batch,
  }) async {
    final existingVideos = await docRef
        .collection('videos')
        .where('deliveryOption', isEqualTo: data['deliveryOption'])
        .get();

    for (var doc in existingVideos.docs) {
      batch.delete(doc.reference);
    }

    final videoRef = docRef.collection('videos').doc();
    batch.set(videoRef, {
      'url': data['videoUrl'],
      'fileName': data['videoFileName'],
      'uploadDate': FieldValue.serverTimestamp(),
      'status': 'completed',
      'deliveryOption': data['deliveryOption'],
    });

    batch.update(docRef, {
      'closedStatus': data['deliveryOption'] == 'Đóng gói' ? true : existingData['closedStatus'],
      'shippingStatus': data['deliveryOption'] == 'Giao hàng' ? true : existingData['shippingStatus'],
      'returnStatus': data['deliveryOption'] == 'Trả hàng' ? true : existingData['returnStatus'],
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  void _createNewDocument({
    required Map<String, dynamic> data,
    required String userId,
    required bool isQRCode,
    required String storeId,
    required WriteBatch batch,
  }) {
    final newDocRef = FirebaseFirestore.instance.collection('orders').doc();

    batch.set(newDocRef, {
      'code': data['code'],
      'userId': userId,
      'storeId': storeId,
      'type': isQRCode ? 'QR_CODE' : 'BAR_CODE',
      'closedStatus': data['deliveryOption'] == 'Đóng gói',
      'shippingStatus': data['deliveryOption'] == 'Giao hàng',
      'returnStatus': data['deliveryOption'] == 'Trả hàng',
      'createDate': FieldValue.serverTimestamp(),
    });

    final videoRef = newDocRef.collection('videos').doc();
    batch.set(videoRef, {
      'url': data['videoUrl'],
      'fileName': data['videoFileName'],
      'uploadDate': FieldValue.serverTimestamp(),
      'status': 'completed',
      'deliveryOption': data['deliveryOption'],
    });
  }
}