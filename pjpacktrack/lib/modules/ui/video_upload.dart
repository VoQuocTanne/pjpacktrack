import 'dart:io';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

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

      final videoFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(filePath)}';
      final videoKey = 'videos/$videoFileName';

      final uploadFile = await _uploadToAWS(filePath, videoKey);
      final videoUrl = await _getVideoUrl(videoKey);

      await _handleFirestoreUpload(videoUrl, videoFileName);

      uploadFile.dispose();
    } catch (e) {
      _showMessage('Lỗi trong quá trình xử lý: $e');
    }
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

  Future<void> _handleFirestoreUpload(String videoUrl, String videoFileName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid)
        .where('code', isEqualTo: lastScannedCode)
        .get();

    final doc = orderSnapshot.docs.firstOrNull;
    final docRef = doc?.reference;


    if (docRef != null) {
      await _handleExistingDocument(docRef, videoUrl, videoFileName, doc!.data());
    } else {
      await _createNewDocument(videoUrl, videoFileName, currentUser.uid);
    }
  }

  Future<void> _handleExistingDocument(DocumentReference docRef,
      String videoUrl, String videoFileName, Map<String, dynamic> data) async {
    // Check if video exists for this deliveryOption
    final videoQuery = await docRef
        .collection('videos')
        .where('deliveryOption', isEqualTo: selectedDeliveryOption)
        .get();

    // if (videoQuery.docs.isNotEmpty) {
    //   // Delete old video for this deliveryOption
    //   await videoQuery.docs.first.reference.delete();
    // }

    // Add new video for this deliveryOption
    await _addNewVideo(docRef, videoUrl, videoFileName);

    // Update status flags based on deliveryOption
    await _updateDeliveryStatus(docRef, data);

    _showMessage(
        'Video đã được cập nhật cho trạng thái $selectedDeliveryOption');
  }

  Future<void> _createNewDocument(String videoUrl, String videoFileName, String userId) async {
    final newDocRef = FirebaseFirestore.instance.collection('orders').doc();

    // Add data for the new order document
    await newDocRef.set({
      'code': lastScannedCode,
      'userId': userId,
      'type': isQRCode ? 'QR_CODE' : 'BAR_CODE',
      'closedStatus': selectedDeliveryOption == 'Đóng gói',
      'shippingStatus': selectedDeliveryOption == 'Giao hàng',
      'returnStatus': selectedDeliveryOption == 'Trả hàng',
    });

    // Now, add a new video document to the videos subcollection and get its videoId
    final videoDocRef = await _addNewVideo(newDocRef, videoUrl, videoFileName);

    _showMessage('Video đã được lưu cho đơn hàng');
  }

  Future<void> _updateDeliveryStatus(
      DocumentReference docRef, Map<String, dynamic> data) async {
    await docRef.update({
      'closedStatus':
          selectedDeliveryOption == 'Đóng gói' ? true : data['closedStatus'],
      'shippingStatus':
          selectedDeliveryOption == 'Giao hàng' ? true : data['shippingStatus'],
      'returnStatus':
          selectedDeliveryOption == 'Trả hàng' ? true : data['returnStatus'],
    });
  }

  Future<DocumentReference> _addNewVideo(
      DocumentReference docRef, String videoUrl, String videoFileName) async {
    // Create a new document in the 'videos' subcollection
    final newVideoRef = docRef.collection('videos').doc(); // This generates a new unique ID

    // Set data for the video document
    await newVideoRef.set({
      'url': videoUrl,
      'fileName': videoFileName,
      'uploadDate': FieldValue.serverTimestamp(),
      'status': 'completed',
      'deliveryOption': selectedDeliveryOption,
    });

    return newVideoRef; // Return the reference of the newly created video document
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
