import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';

class RecordingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RecordingScreen({super.key, required this.cameras});

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _cameraController;
  bool _isRecording = false;
  bool _isScanning = true;
  final List<String> _videoPaths = [];

  final AwsCredentialsConfig credentialsConfig = AwsCredentialsConfig(
    accessKey: AwsConfig.accessKey, // Sử dụng giá trị từ AwsConfig
    secretKey: AwsConfig.secretKey,
    bucketName: AwsConfig.bucketName,
    region: AwsConfig.region,
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (_cameraController != null && !_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi bắt đầu quay video: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video đã lưu tại: ${videoFile.path}')),
        );

        //await _uploadVideoToAWS(videoFile.path);

        setState(() {
          _isScanning = true; // Bật lại trạng thái quét sau khi lưu video
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi dừng quay video: $e')),
        );
      }
    }
  }

  Future<void> _uploadVideoToAWS(String filePath) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải video lên AWS...')),
      );

      UploadTaskConfig uploadConfig = UploadTaskConfig(
        credentailsConfig: credentialsConfig,
        url: 'videos/${p.basename(filePath)}',
        uploadType: UploadType.file,
        file: File(filePath),
      );

      UploadFile uploadFile = UploadFile(config: uploadConfig);
      uploadFile.uploadProgress.listen((event) {
        print('Tiến trình tải: ${event[0]} / ${event[1]}');
      });

      await uploadFile.upload().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải lên thành công: $value')),
        );
        uploadFile.dispose();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải lên AWS: $e')),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR & Quay Video'),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Stack(
        children: [
          // CameraPreview chiếm toàn bộ màn hình
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          // MobileScanner nằm trên cùng và chỉ hoạt động khi quét
          if (_isScanning)
            Positioned.fill(
              child: MobileScanner(onDetect: (BarcodeCapture capture) async {
                if (_isScanning && !_isRecording) {
                  final barcode = capture.barcodes.first;
                  final String? code = barcode.rawValue;

                  if (code != null) {
                    setState(() {
                      _isScanning = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mã QR/Barcode: $code')),
                    );

                    await _startRecording();
                  }
                }
              }),
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
}
