import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/modules/ui/delivery_option.dart';
import 'package:pjpacktrack/modules/ui/video_upload.dart';
import 'ObjectDetectorPainter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
  static const String STOP_CODE = "STOP";
  bool _isProcessing = false;
  late ObjectDetector _objectDetector;
  List<DetectedObject> _detectedObjects = [];
  Map<String, int> _productCounts = {};
  int _totalProducts = 0;

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
    _initializeObjectDetector();
  }

  Future<void> _initializeObjectDetector() async {
    final path = 'assets/ml/object_labeler.tflite';
    final modelPath = await _getModel(path);

    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.5,
    );

    _objectDetector = ObjectDetector(options: options);
  }

  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final String modelPath =
        '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(path.dirname(modelPath)).create(recursive: true);
    final file = File(modelPath);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
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
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        _cameraController = CameraController(
          widget.cameras[0],
          ResolutionPreset.medium,  // Use medium resolution
          enableAudio: true,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.yuv420  // For Android
              : ImageFormatGroup.bgra8888,  // For iOS
        );

        await _cameraController!.initialize();

        // Add a small delay before starting image stream
        await Future.delayed(Duration(milliseconds: 300));

        if (mounted) {
          // Start image stream with lower frame rate
          await _cameraController!.startImageStream((image) {
            if (!_isRecording || !mounted) return;
            _processImage(image);
          });

          setState(() {});
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }
  Widget _buildDebugOverlay() {
    return Positioned(
      top: 160,  // Below product counts
      left: 16,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Info:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Processing: ${_isRecording ? "Yes" : "No"}',
              style: TextStyle(color: Colors.green),
            ),
            Text(
              'Objects Found: ${_detectedObjects.length}',
              style: TextStyle(color: Colors.yellow),
            ),
            if (_detectedObjects.isNotEmpty)
              ..._detectedObjects.map((obj) =>
                  Text(
                    'Labels: ${obj.labels.map((l) => "${l.text}(${(l.confidence * 100).toStringAsFixed(1)}%)").join(", ")}',
                    style: TextStyle(color: Colors.white),
                  )
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(CameraImage image) async {
    if (!mounted || !_isRecording || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      print("------- Frame Processing Start -------");
      print("Image Size: ${image.width}x${image.height}");
      print("Planes: ${image.planes.length}");
      print("Format: ${image.format.raw}");

      // Get camera rotation
      final camera = widget.cameras[0];
      final imageRotation = InputImageRotation.values[camera.sensorOrientation ~/ 90];

      // Process image bytes
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // Create InputImage
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: imageRotation,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      print("Processing with ML Kit...");
      final objects = await _objectDetector.processImage(inputImage);
      print("Detection Results:");
      print("Total Objects: ${objects.length}");

      if (objects.isNotEmpty) {
        for (int i = 0; i < objects.length; i++) {
          final obj = objects[i];
          print("Object $i:");
          print("  Bounds: ${obj.boundingBox}");
          print("  Labels: ${obj.labels.map((l) =>
          "${l.text}(${(l.confidence * 100).toStringAsFixed(1)}%)"
          ).join(", ")}");
        }
      }

      _updateDetections(objects);
      print("------- Frame Processing End -------");

    } catch (e, stackTrace) {
      print('Error processing image: $e');
      print('Stack trace: $stackTrace');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _updateDetections(List<DetectedObject> objects) {
    setState(() {
      _detectedObjects = objects;
      // Update product counts
      _productCounts.clear();
      for (var object in objects) {
        for (var label in object.labels) {
          if (label.confidence > 0.7) {
            String productName = label.text;
            _productCounts[productName] =
                (_productCounts[productName] ?? 0) + 1;
          }
        }
      }

      _totalProducts =
          _productCounts.values.fold(0, (sum, count) => sum + count);
    });
  }

  Future<void> _startRecording() async {
    // First stop the scanner before initializing camera
    await _scannerController?.stop();
    await _initializeCamera();

    if (_cameraController != null && !_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _isContinuousScanning = _continuousRecording;
          _isScanning = false;  // Important: set scanning to false
        });
      } catch (e) {
        print('Recording start error: $e');
      }
    }
  }

  Future<void> _stopAndReset() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User not logged in.");
      return;
    }

    try {
      // Lấy packageId từ user
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        print("User document not found.");
        return;
      }

      final userData = userDoc.data();
      final String packageId = userData?['packageId'] ?? '';
      if (packageId.isEmpty) {
        print("PackageId not found for user.");
        return;
      }

      // Lấy limitData từ package
      final packageDoc = await FirebaseFirestore.instance
          .collection('packages')
          .doc(packageId)
          .get();
      if (!packageDoc.exists) {
        print("Package document not found.");
        return;
      }

      final packageData = packageDoc.data();
      final int limitData = packageData?['dataLimit'] ?? 10.0;
      print('Data limit: ${limitData.toStringAsFixed(2)} MB');
      if (_cameraController != null && _isRecording) {
        // Dừng quay video và lấy file
        final XFile videoFile = await _cameraController!.stopVideoRecording();

        // Kiểm tra kích thước file video
        final File file = File(videoFile.path);
        final int fileSize = await file.length(); // Kích thước tính bằng byte
        final double fileSizeMB = fileSize / (1024 * 1024); // Đổi thành MB

        print('File size: ${fileSizeMB.toStringAsFixed(2)} MB');

        if (fileSizeMB > limitData) {
          // Xóa video nếu vượt quá dung lượng
          await file.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Video vượt quá giới hạn $limitData MB (${fileSizeMB.toStringAsFixed(2)} MB). Vui lòng quay lại.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
          print(
              'Video vượt quá giới hạn $limitData MB (${fileSizeMB.toStringAsFixed(2)} MB). Vui lòng quay lại.');
          setState(() {
            _isRecording = false;
            _isScanning = true;
          });

          return;
        }

        // Thêm video vào danh sách nếu đạt yêu cầu
        setState(() {
          _videoPaths.add(videoFile.path);
          _isRecording = false;
        });

        // Upload video
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

        // Cleanup và reset
        await _cameraController?.dispose();
        _cameraController = null;
        setState(() {
          _isScanning = true;
          _lastScannedCode = null;
        });
        await _initializeCamera();
        _initializeScannerController();
        // 6. Sau đó mới khởi tạo camera
        if (!_continuousRecording) {
          setState(() => _selectedDeliveryOption = null);
          await Future.delayed(const Duration(milliseconds: 500)); // Đợi thêm
          await _initializeCamera();
        }

        // 7. Đảm bảo scanner được kích hoạt
        setState(() {
          _isScanning = true;
        });
      }
    } catch (e) {
      print('Error in _stopAndReset: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
      setState(() {
        _isRecording = false;
        _isScanning = true;
      });
    }
  }

  @override
  void dispose() {
    _objectDetector.close();
    _cameraController?.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Widget _buildDetectionOverlay() {
    print(
        "Building detection overlay. Objects count: ${_detectedObjects.length}");
    return CustomPaint(
      painter: ObjectDetectorPainter(
        _detectedObjects,
        Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  Widget _buildProductCounts() {
    return Positioned(
      top: 120,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detected Products:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            ..._productCounts.entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Divider(color: Colors.white30),
            Text(
              'Total: $_totalProducts',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
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
                // Detection overlay on top of camera preview
                Positioned.fill(
                  child: _buildDetectionOverlay(),
                ),
                // Product counts display
                _buildProductCounts(),
                if (kDebugMode) _buildDebugOverlay(),  // Only show in debug mode
                Positioned.fill(
                  child: Opacity(
                    opacity: 1,
                    child: _buildScanner(),
                  ),
                ),
              ],
            )
          else if (_isRecording && _cameraController != null)
            Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned.fill(
                  child: _buildDetectionOverlay(),
                ),
                _buildProductCounts(),
              ],
            )
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
      if (!_isRecording && code != STOP_CODE) {
        // Chế độ quét bình thường
        _isQRCode = barcode.format == BarcodeFormat.qrCode;
        setState(() {
          _isScanning = false;
          _lastScannedCode = code;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text('${_isQRCode ? "QR Code" : "Barcode"}: $code')),
        // );

        try {
          await _startRecording();
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
