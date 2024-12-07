import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/modules/ui/delivery_option.dart';

class RecordingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RecordingScreen({super.key, required this.cameras});

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _cameraController;
  MobileScannerController? _scannerController;
  bool _isRecording = false;
  bool _isScanning = true;
  bool _isFlashOn = false;
  String? _lastScannedCode;
  String? _selectedDeliveryOption;
  final List<String> _videoPaths = [];

  final AwsCredentialsConfig credentialsConfig = AwsCredentialsConfig(
    accessKey: AwsConfig.accessKey,
    secretKey: AwsConfig.secretKey,
    bucketName: AwsConfig.bucketName,
    region: AwsConfig.region,
  );

  @override
  void initState() {
    super.initState();
    _initializeScannerController();
  }

  void _initializeScannerController() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.qrCode],
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: true,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  void _toggleFlash() async {
    if (_isScanning) {
      await _scannerController?.toggleTorch();
      setState(() => _isFlashOn = !_isFlashOn);
    } else if (_cameraController != null) {
      try {
        final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
        await _cameraController!.setFlashMode(newFlashMode);
        setState(() => _isFlashOn = !_isFlashOn);
      } catch (e) {
        print('Flash toggle error: $e');
      }
    }
  }

  Future<void> _startRecording() async {
    await _scannerController?.stop();
    await _initializeCamera();

    if (_cameraController != null && !_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);
      } catch (e) {
        print('Recording start error: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController != null && _isRecording) {
      try {
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoPaths.add(videoFile.path);
        });

        await _uploadVideoToAWS(videoFile.path);

        _cameraController?.dispose();
        _cameraController = null;

        setState(() {
          _isScanning = true;
          _lastScannedCode = null;
        });

        _initializeScannerController();
      } catch (e) {
        print('Recording stop error: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR & Quay Video'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isScanning && !_isRecording && _selectedDeliveryOption != null)
            MobileScanner(
              controller: _scannerController,
              onDetect: (BarcodeCapture capture) async {
                if (_lastScannedCode == null) {
                  final barcode = capture.barcodes.first;
                  final String? code = barcode.rawValue;

                  if (code != null) {
                    setState(() {
                      _isScanning = false;
                      _lastScannedCode = code;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mã QR/Barcode: $code')),
                    );

                    await _startRecording();
                  }
                }
              },
            ),
          if (!_isScanning && _isRecording && _cameraController != null)
            CameraPreview(_cameraController!),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: DeliveryOptionsWidget(
                onOptionSelected: (String option) {
                  setState(() => _selectedDeliveryOption = option);
                  _saveDeliveryOption(option);
                },
              ),
            ),
          ),
          if (_selectedDeliveryOption == null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Vui lòng chọn loại giao hàng trước khi quét mã',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.5),
              offset: const Offset(0, -1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _isRecording ? _stopRecording : null,
          icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
          label: const Text('Dừng Quay Video'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDeliveryOption(String option) async {
    try {
      await FirebaseFirestore.instance.collection('delivery_options').add({
        'option': option,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving delivery option: $e');
    }
  }

  Future<void> _uploadVideoToAWS(String filePath) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải video lên AWS...')),
      );

      final videoFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(filePath)}';
      final videoKey = 'videos/$videoFileName';

      // Cấu hình tải video lên AWS
      UploadTaskConfig uploadConfig = UploadTaskConfig(
        credentailsConfig: credentialsConfig,
        url: videoKey,
        uploadType: UploadType.file,
        file: File(filePath),
      );

      UploadFile uploadFile = UploadFile(config: uploadConfig);
      uploadFile.uploadProgress.listen((event) {
        print('Tiến trình tải: ${event[0]} / ${event[1]}');
      });

      await uploadFile.upload().then((value) async {
        final videoUrl =
            'https://${credentialsConfig.bucketName}.s3.${credentialsConfig.region}.amazonaws.com/$videoKey';

        // Kiểm tra mã đơn hàng đã tồn tại trong Firestore
        final videoDocRef = FirebaseFirestore.instance
            .collection('videos')
            .doc(_lastScannedCode); // Lấy document với ID là qrCode

        final videoDocSnapshot = await videoDocRef.get();

        if (videoDocSnapshot.exists) {
          // Nếu mã đơn hàng đã tồn tại, kiểm tra trạng thái deliveryOption và trạng thái hiện tại
          final videoData = videoDocSnapshot.data()!;
          final currentDeliveryOption = videoData['deliveryOption'];
          final closedStatus = videoData['closedStatus'];
          final shippingStatus = videoData['shippingStatus'];
          final returnStatus = videoData['returnStatus'];

          if (currentDeliveryOption != _selectedDeliveryOption) {
            // Nếu deliveryOption khác nhau, cập nhật video trong mảng videos
            final newVideoRef = videoDocRef.collection('videos').doc();
            await newVideoRef.set({
              'url': videoUrl,
              'fileName': videoFileName,
              'uploadDate': FieldValue.serverTimestamp(),
              'status': 'completed',
            });

            // Cập nhật lại các trạng thái của mã đơn hàng
            await videoDocRef.update({
              'deliveryOption': _selectedDeliveryOption,
              'closedStatus': closedStatus, // Giữ nguyên trạng thái đóng hàng
              'shippingStatus': shippingStatus, // Giữ nguyên trạng thái giao hàng
              'returnStatus': returnStatus, // Giữ nguyên trạng thái trả hàng
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video đã được cập nhật thành công')),
            );
          } else {
            // Nếu deliveryOption giống nhau, thông báo cho người dùng
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Video đã tồn tại với mã đơn hàng và deliveryOption này'),
              ),
            );
          }
        } else {
          // Nếu mã đơn hàng chưa tồn tại, tạo mới tài liệu và lưu video
          await videoDocRef.set({
            'deliveryOption': _selectedDeliveryOption,
            'closedStatus': false, // Trạng thái đóng hàng ban đầu
            'shippingStatus': false, // Trạng thái giao hàng ban đầu
            'returnStatus': false, // Trạng thái trả hàng ban đầu
          });

          final newVideoRef = videoDocRef.collection('videos').doc();
          await newVideoRef.set({
            'url': videoUrl,
            'fileName': videoFileName,
            'uploadDate': FieldValue.serverTimestamp(),
            'status': 'completed',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video đã được tải lên và lưu thành công')),
          );
        }
        uploadFile.dispose();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi trong quá trình xử lý: $e')),
      );
    }
  }

}
