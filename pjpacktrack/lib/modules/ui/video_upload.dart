import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VideoUploader {
  final BuildContext context;
  final AwsCredentialsConfig credentialsConfig;
  final String lastScannedCode;
  final String selectedDeliveryOption;
  final bool isQRCode;

  VideoUploader({
    required this.context,
    required this.credentialsConfig,
    required this.lastScannedCode,
    required this.selectedDeliveryOption,
    required this.isQRCode,
  });

  Future<void> uploadVideo(String filePath) async {
    try {
      _showMessage('Đang tải video lên AWS...');
      final uploadData = await _prepareVideoUpload(filePath);
      await _handleFirestoreUpload([uploadData]);
    } catch (e) {
      _showMessage('Lỗi trong quá trình xử lý: $e');
    }
  }

  Future<void> uploadMultipleVideos(List<String> filePaths) async {
    try {
      _showMessage('Đang tải videos lên AWS...');
      final uploadResults =
          await Future.wait(filePaths.map((path) => _prepareVideoUpload(path)));
      await _handleFirestoreUpload(uploadResults);
    } catch (e) {
      _showMessage('Lỗi trong quá trình xử lý: $e');
    }
  }

  Future<Map<String, dynamic>> _prepareVideoUpload(String filePath) async {
    final videoFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(filePath)}';
    final videoKey = 'videos/$videoFileName';

    final uploadFile = await _uploadToAWS(filePath, videoKey);
    final videoUrl = _getVideoUrl(videoKey);
    uploadFile.dispose();

    return {
      'videoUrl': videoUrl,
      'videoFileName': videoFileName,
      'code': lastScannedCode,
      'deliveryOption': selectedDeliveryOption,
    };
  }

  Future<UploadFile> _uploadToAWS(String filePath, String videoKey) async {
    final uploadConfig = UploadTaskConfig(
      credentailsConfig: credentialsConfig,
      url: videoKey,
      uploadType: UploadType.file,
      file: File(filePath),
    );

    final uploadFile = UploadFile(config: uploadConfig);
    uploadFile.uploadProgress.listen((event) {
      print('Tiến trình tải: ${event[0]} / ${event[1]}');
    });

    await uploadFile.upload();
    return uploadFile;
  }

  String _getVideoUrl(String videoKey) {
    return 'https://${credentialsConfig.bucketName}.s3.${credentialsConfig.region}.amazonaws.com/$videoKey';
  }

  Future<bool> _canUploadMore(String userId, int uploadCount) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return false;

    final data = userDoc.data()!;
    final quantity = data['quantity'] ?? 0;
    final rank = data['rank'] ?? 'free';
    final limit = rank == 'free' ? 50 : (data['limit'] ?? 50);

    return (quantity + uploadCount) <= limit;
  }

  Future<void> _incrementQuantity(
      String userId, int increment, WriteBatch batch) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    final currentQuantity = data['quantity'] ?? 0;
    final rank = data['rank'] ?? 'free';
    final limit = rank == 'free' ? 50 : (data['limit'] ?? 50);

    final newQuantity = currentQuantity + increment;
    if (newQuantity <= limit) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      batch.update(userRef, {'quantity': newQuantity});
    }
  }

  Future<void> _handleFirestoreUpload(
      List<Map<String, dynamic>> uploadData) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (!await _canUploadMore(currentUser.uid, uploadData.length)) {
      _showMessage('Đã đạt giới hạn tải lên');
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
          doc.reference,
          data['videoUrl'],
          data['videoFileName'],
          data['deliveryOption'],
          doc.data(),
          batch,
        );
      } else {
        _createNewDocument(
          data['videoUrl'],
          data['videoFileName'],
          currentUser.uid,
          data['code'],
          data['deliveryOption'],
          batch,
        );
      }
    }

    await _incrementQuantity(currentUser.uid, uploadData.length, batch);
    await batch.commit();

    _showMessage(
        uploadData.length > 1
            ? 'Tất cả videos đã được cập nhật'
            : 'Video đã được cập nhật cho đơn hàng'
    );
  }

  Future<void> _handleExistingDocument(
      DocumentReference docRef,
      String videoUrl,
      String videoFileName,
      String deliveryOption,
      Map<String, dynamic> data,
      WriteBatch batch,
      ) async {
    // Tìm video cũ với cùng deliveryOption
    final existingVideos = await docRef
        .collection('videos')
        .where('deliveryOption', isEqualTo: deliveryOption)
        .get();

    // Xóa tất cả videos cũ có cùng deliveryOption
    for (var doc in existingVideos.docs) {
      batch.delete(doc.reference);
    }

    // Tạo document mới cho video trong collection videos
    final videoRef = docRef.collection('videos').doc();
    batch.set(videoRef, {
      'url': videoUrl,
      'fileName': videoFileName,
      'uploadDate': FieldValue.serverTimestamp(),
      'status': 'completed',
      'deliveryOption': deliveryOption,
    });

    batch.update(docRef, {
      'closedStatus': deliveryOption == 'Đóng gói' ? true : data['closedStatus'],
      'shippingStatus': deliveryOption == 'Giao hàng' ? true : data['shippingStatus'],
      'returnStatus': deliveryOption == 'Trả hàng' ? true : data['returnStatus'],
      'lastUpdated': FieldValue.serverTimestamp(), // Thêm thời gian cập nhật
    });
  }

  void _createNewDocument(
    String videoUrl,
    String videoFileName,
    String userId,
    String code,
    String deliveryOption,
    WriteBatch batch,
  ) {
    final newDocRef = FirebaseFirestore.instance.collection('orders').doc();

    batch.set(newDocRef, {
      'code': code,
      'userId': userId,
      'type': isQRCode ? 'QR_CODE' : 'BAR_CODE',
      'closedStatus': deliveryOption == 'Đóng gói',
      'shippingStatus': deliveryOption == 'Giao hàng',
      'returnStatus': deliveryOption == 'Trả hàng',
      'createDate': FieldValue.serverTimestamp(),
    });

    final videoRef = newDocRef.collection('videos').doc();
    batch.set(videoRef, {
      'url': videoUrl,
      'fileName': videoFileName,
      'uploadDate': FieldValue.serverTimestamp(),
      'status': 'completed',
      'deliveryOption': deliveryOption,
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
