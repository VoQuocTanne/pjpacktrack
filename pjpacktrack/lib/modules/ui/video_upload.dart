import 'dart:io';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _handleFirestoreUpload(
      String videoUrl, String videoFileName) async {
    final qrSnapshot = await FirebaseFirestore.instance
        .collection('qr_codes')
        .doc(lastScannedCode)
        .get();

    final barcodeSnapshot = await FirebaseFirestore.instance
        .collection('barcodes')
        .doc(lastScannedCode)
        .get();

    final videoDocRef = qrSnapshot.exists
        ? qrSnapshot.reference
        : barcodeSnapshot.exists
            ? barcodeSnapshot.reference
            : null;

    if (videoDocRef != null) {
      final data =
          qrSnapshot.exists ? qrSnapshot.data()! : barcodeSnapshot.data()!;
      await _handleExistingDocument(videoDocRef, videoUrl, videoFileName, data);
    } else {
      await _createNewDocument(videoUrl, videoFileName);
    }
  }

  Future<void> _handleExistingDocument(DocumentReference docRef,
      String videoUrl, String videoFileName, Map<String, dynamic> data) async {
    // Check if video exists for this deliveryOption
    final videoQuery = await docRef
        .collection('videos')
        .where('deliveryOption', isEqualTo: selectedDeliveryOption)
        .get();

    if (videoQuery.docs.isNotEmpty) {
      // Delete old video for this deliveryOption
      await videoQuery.docs.first.reference.delete();
    }

    // Add new video for this deliveryOption
    await _addNewVideo(docRef, videoUrl, videoFileName);

    // Update status flags based on deliveryOption
    await _updateDeliveryStatus(docRef, data);

    _showMessage(
        'Video đã được cập nhật cho trạng thái $selectedDeliveryOption');
  }

  Future<void> _createNewDocument(String videoUrl, String videoFileName) async {
    final collection = isQRCode ? 'qr_codes' : 'barcodes';
    final newDocRef =
        FirebaseFirestore.instance.collection(collection).doc(lastScannedCode);

    await newDocRef.set({
      'closedStatus': selectedDeliveryOption == 'Đóng gói',
      'shippingStatus': selectedDeliveryOption == 'Giao hàng',
      'returnStatus': selectedDeliveryOption == 'Trả hàng',
      'isQRCode': isQRCode,
    });

    await _addNewVideo(newDocRef, videoUrl, videoFileName);
    _showMessage('Video đã được lưu cho trạng thái $selectedDeliveryOption');
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

  Future<void> _addNewVideo(
      DocumentReference docRef, String videoUrl, String videoFileName) async {
    final newVideoRef = docRef.collection('videos').doc();
    await newVideoRef.set({
      'url': videoUrl,
      'fileName': videoFileName,
      'uploadDate': FieldValue.serverTimestamp(),
      'status': 'completed',
      'deliveryOption': selectedDeliveryOption,
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
