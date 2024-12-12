import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/modules/ui/delivery_option.dart';
import 'package:pjpacktrack/modules/ui/video_upload.dart';

import 'bua.dart';
import 'bua1.dart';

class RecordingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String storeId;

  RecordingScreen({super.key, required this.cameras, required this.storeId});

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _cameraController;
  MobileScannerController? _scannerController;
  bool _isRecording = false;
  bool _isScanning = true;
  bool _isFlashOn = false;
  bool _isQRCode = false;
  bool _continuousRecording = false;
  String? _lastScannedCode;
  String? _selectedDeliveryOption;
  final List<String> _videoPaths = [];
  double _currentBrightness = 0;
  String _brightnessWarning = "";
  static const String STOP_CODE = "STOP";
  bool _isContinuousScanning = false;
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
      formats: [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.codabar,
        BarcodeFormat.ean8,
        BarcodeFormat.ean13,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
  }

  Future<void> _initializeCamera() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        _cameraController = CameraController(
          widget.cameras[0],
          ResolutionPreset.veryHigh,
          enableAudio: true,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _startRecording() async {
    await _initializeCamera();

    if (_cameraController != null && !_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _isContinuousScanning = _continuousRecording;
        });
      } catch (e) {
        print('Recording start error: $e');
      }
    }
  }

  Future<void> _stopAndReset() async {
    if (_cameraController != null && _isRecording) {
      try {
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _videoPaths.add(videoFile.path);
        });
        final uploader = VideoUploader(
          context: context,
          credentialsConfig: credentialsConfig,
          lastScannedCode: _lastScannedCode!,
          selectedDeliveryOption: _selectedDeliveryOption!,
          isQRCode: _isQRCode,
          storeId: widget.storeId,
        );
        await uploader.uploadVideo(videoFile.path);
        print('Upload success');

        // Clean up camera completely
        await _cameraController?.dispose();
        _cameraController = null;

        // Clean up scanner completely
        await _scannerController?.dispose();
        _scannerController = null;

        setState(() {
          _isRecording = false;
          _isScanning = true;
          _isContinuousScanning = false;
          _lastScannedCode = null;
        });

        if (!_continuousRecording) {
          setState(() => _selectedDeliveryOption = null);
        }

        // Initialize fresh instances
        _initializeScannerController();
        await _initializeCamera();
      } catch (e) {
        print('Recording stop error: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scannerController?.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Show both camera preview and scanner when recording continuously
          if (_isRecording && _continuousRecording)
            Stack(
              children: [
                if (_cameraController != null)
                  Positioned.fill(
                    child: CameraPreview(_cameraController!),
                  ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 1,
                    child: _buildScanner(),
                  ),
                ),
              ],
            )
          else if (_isRecording && _cameraController != null)
            CameraPreview(_cameraController!)
          else if (_isScanning && _selectedDeliveryOption != null)
              _buildScanner()
          else
              Container(color: Colors.black),
          if (_selectedDeliveryOption != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(_isRecording ? 0.2 : 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDeliveryOption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModeButton('Quay lần lượt', Icons.looks_one,
                            !_continuousRecording),
                        const SizedBox(height: 12),
                        _buildModeButton('Quay liên tục', Icons.repeat,
                            _continuousRecording),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: DeliveryOptionsWidget(
                onOptionSelected: _handleDeliveryOptionSelected,
              ),
            ),
          ),
          if (_selectedDeliveryOption == null)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.touch_app, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Chọn hình thức để bắt đầu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Bottom status
          if (_isRecording)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 12),
                      SizedBox(width: 8),
                      Text(
                        'Đang quay video',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildModeButton(String label, IconData icon, bool isSelected) {
    return InkWell(
      onTap: _isRecording
          ? null
          : () {
              setState(() {
                // Thay đổi trạng thái của _continuousRecording dựa trên lựa chọn
                _continuousRecording = (label == 'Quay liên tục');
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.tealAccent : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              // Màu icon tùy thuộc vào trạng thái
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                // Màu chữ tùy thuộc vào trạng thái
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isRecording ? _stopAndReset : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isRecording ? Icons.stop : Icons.videocam),
              const SizedBox(width: 8),
              Text(
                _isRecording ? 'Dừng quay video' : 'Chờ quét mã',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
        controller: _scannerController,
        onDetect: _handleDetection,
      );
  }

  void _handleDeliveryOptionSelected(String option) {
    setState(() => _selectedDeliveryOption = option);
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      if (_isRecording && _continuousRecording) {
        // During continuous recording, only process STOP code
        if (code == STOP_CODE) {
          await _stopAndReset();
        }
      } else if (!_isRecording) {
        // Normal scanning mode
        _isQRCode = barcode.format == BarcodeFormat.qrCode;
        setState(() {
          _isScanning = false;
          _lastScannedCode = code;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_isQRCode ? "QR Code" : "Barcode"}: $code')),
        );

        await _startRecording();
      }
    }
  }
}
