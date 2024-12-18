import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/modules/ui/delivery_option.dart';
import 'package:pjpacktrack/modules/ui/fake_api/product_code_service.dart';
import 'package:pjpacktrack/modules/ui/video_upload.dart';

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
  bool _continuousRecording = true;
  String? _lastScannedCode;
  String? _selectedDeliveryOption;
  final List<String> _videoPaths = [];
  static const String STOP_CODE = "STOP";
  bool _isContinuousScanning = false;
  String? _productName;
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
          ResolutionPreset.max, // Change to max resolution
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.jpeg, // Add format group
        );

        await _cameraController!.initialize();

        // Configure video recording settings
        await _cameraController!.prepareForVideoRecording();

        // Set video resolution if available
        final available = await availableCameras();
        if (available.isNotEmpty) {
          final resolution = available[0].sensorOrientation;
          // Adjust based on sensor capabilities
          await _cameraController!.lockCaptureOrientation();
        }

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
        // 1. Dừng quay và lấy file video
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _videoPaths.add(videoFile.path);
        });

        // 2. Upload video
        final uploader = VideoUploader(
          context: context,
          credentialsConfig: credentialsConfig,
          lastScannedCode: _lastScannedCode ?? 'UNKNOWN',
          selectedDeliveryOption: _selectedDeliveryOption ?? 'UNKNOWN',
          isQRCode: _isQRCode,
          storeId: widget.storeId,
        );
        await uploader.uploadVideo(videoFile.path);
        print('Upload completed successfully');

        // 3. Cleanup controllers
        if (_cameraController != null) {
          await _cameraController?.dispose();
          _cameraController = null;
        }
        if (_scannerController != null) {
          await _scannerController?.dispose();
          _scannerController = null;
        }

        // 4. Reset state
        setState(() {
          _isRecording = false;
          _isScanning = true;
          _lastScannedCode = null;
        });

        _initializeScannerController();

        if (!_continuousRecording) {
          setState(() => _selectedDeliveryOption = null);
          await _initializeCamera();
        }

        setState(() {
          _isScanning = true;
        });
      } catch (e) {
        print('Stop and reset error: $e');
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
          Positioned(
            top: 10,
            right: 0,
            left: 0,
            child: DeliveryOptionsWidget(
              onOptionSelected: _handleDeliveryOptionSelected,
            ),
          ),
          if (_selectedDeliveryOption == null)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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

          // if (_productName != null)
          //   Positioned(
          //     top: 120,
          //     right: 0,
          //     child: Center(
          //       child: Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          //         decoration: BoxDecoration(
          //           color: Colors.black.withOpacity(0.7),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment
          //               .start, //Canh nội dung sang phải màn hình
          //           children: [
          //             // Text(
          //             //   'Sản phẩm:',
          //             //   style: TextStyle(
          //             //     color: Colors.white,
          //             //     fontSize: 18,
          //             //     fontWeight: FontWeight.bold,
          //             //   ),
          //             // ),
          //             ..._productName!
          //                 .split(', ')
          //                 .map((product) => Text(
          //                       product,
          //                       style: TextStyle(
          //                         color: Colors.white,
          //                         fontSize: 16,
          //                       ),
          //                     ))
          //                 .toList(),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          if (_productName != null)
            Positioned(
              top: 120,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
                    children: [
                      // Hiển thị tên sản phẩm
                      ..._productName!
                          .split(', ')
                          .map((product) => Text(
                                product,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ))
                          .toList(),
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

  // Future<void> _handleDetection(BarcodeCapture capture) async {
  //   final barcode = capture.barcodes.first;
  //   final String? code = barcode.rawValue;

  //   if (code != null) {
  //     if (!_isRecording && code != STOP_CODE) {
  //       // Chế độ quét bình thường
  //       _isQRCode = barcode.format == BarcodeFormat.qrCode;
  //       setState(() {
  //         _isScanning = false;
  //         _lastScannedCode = code;
  //       });

  //       try {
  //         await _startRecording();
  //       } catch (e) {
  //         print('Error during recording: $e');
  //       }
  //     } else if (_isRecording && _continuousRecording && code == STOP_CODE) {
  //       // Chỉ xử lý mã "STOP" khi quay liên tục
  //       try {
  //         await _stopAndReset();
  //       } catch (e) {
  //         print('Error during stopping: $e');
  //       }
  //     }
  //   }
  // }

  void _handleDetection(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      // In ra thông tin chi tiết để debug
      print('Raw Scanned Code: $code');
      print('Barcode Format: ${barcode.format}');

      // Kiểm tra xem mã có phải QR code không (nếu bạn chỉ muốn xử lý QR code)
      if (barcode.format == BarcodeFormat.qrCode) {
        // Kiểm tra mã sản phẩm từ dịch vụ
        final productName = await ProductCodeService.validateProductCode(code);

        if (productName != null && !_isRecording && code != STOP_CODE) {
          setState(() {
            _productName =
                productName; // Lưu tên sản phẩm vào biến _productName
            _isQRCode = true; // Đánh dấu là mã QR hợp lệ
            _isScanning = false; // Ngừng quét mã
            _lastScannedCode = code; // Lưu lại mã quét
          });

          try {
            await _startRecording(); // Bắt đầu quay video sau khi quét mã QR thành công
          } catch (e) {
            print('Error during recording: $e');
          }
        } else if (_isRecording && _continuousRecording && code == STOP_CODE) {
          // Chỉ xử lý mã "STOP" khi quay liên tục
          try {
            await _stopAndReset();
          } catch (e) {
            print('Error during stopping: $e');
          }
        }
      }
    }
  }
}
