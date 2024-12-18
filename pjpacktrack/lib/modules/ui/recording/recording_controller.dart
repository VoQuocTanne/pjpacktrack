import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pjpacktrack/modules/ui/fake_api/matched_order_screen.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_repo/recording_state.dart';
import '../aws_config.dart';
import '../video/video_repo/video_upload_state.dart';
import '../video/video_upload_provider.dart';

final recordingControllerProvider =
    StateNotifierProvider.autoDispose<RecordingController, RecordingState>(
        (ref) {
  return RecordingController(ref);
});
final videoUploadProvider =
    StateNotifierProvider<VideoUploadNotifier, VideoUploadState>((ref) {
  // Bỏ autoDispose
  return VideoUploadNotifier();
});

final cameraControllerProvider =
    Provider.autoDispose<CameraController?>((ref) => null);

final scannerControllerProvider =
    Provider.autoDispose<MobileScannerController?>((ref) => null);

class RecordingController extends StateNotifier<RecordingState> {
  final Ref ref;
  CameraController? _cameraController;
  MobileScannerController? _scannerController;
  static const String STOP_CODE = "STOP";
  List<CameraDescription>? _cameras;
  String? _currentStoreId;
  late final VideoUploadNotifier _uploader;

  RecordingController(this.ref) : super(const RecordingState()) {
    _uploader = ref.read(videoUploadProvider.notifier);
    _initializeScannerController();
  }

  void _initializeScannerController() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      returnImage: false,
    );
    debugPrint('Scanner initialized');
  }

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) return;

    _cameras = cameras;

    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      state = state.copyWith(isInitialized: true);
      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Camera init error: $e');
      state = state.copyWith(isInitialized: false);
      await Future.delayed(const Duration(seconds: 2));
      await initializeCamera(cameras); // Khởi tạo lại camera
    }
  }

  void setStoreId(String storeId) {
    _currentStoreId = storeId;
  }

  Future<void> startRecording() async {
    if (_scannerController != null) {
      await _scannerController!.stop();
      await _scannerController!.dispose();
      _scannerController = null; // Đảm bảo xóa scanner
    }

    if (_cameraController != null && !state.isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        state = state.copyWith(
          isRecording: true,
          isScanning: false, // Ngừng chế độ quét
        );
      } catch (e) {
        debugPrint('Recording start error: $e');
        rethrow;
      }
    }
  }

  Future<void> stopAndReset(String storeId) async {
    if (!state.isRecording || _cameraController == null) return;

    try {
      debugPrint('Stopping recording...');
      final videoFile = await _cameraController!.stopVideoRecording();
      state = state.copyWith(isRecording: false);

      debugPrint('Uploading video...');
      await _uploadVideo(videoFile, storeId, state.lastScannedCode!,
          state.selectedDeliveryOption!, state.isQRCode);

      debugPrint('Resetting controllers...');
      await _cleanupControllers(); // Dọn dẹp trước
      _initializeScannerController();
      await initializeCamera(_cameras!); // Khởi tạo lại CameraController

      state = state.copyWith(
        isRecording: false,
        isScanning: true,
        isInitialized: true,
      );
      debugPrint('Reset complete, ready for new recording.');
    } catch (e) {
      debugPrint('Stop recording error: $e');
      state = state.copyWith(isRecording: false);
    }
  }

  Future<void> _uploadVideo(XFile videoFile, String storeId, String lastCode,
      String deliveryOption, bool isQR) async {
    await _uploader.uploadVideo(
      filePath: videoFile.path,
      credentialsConfig: AwsCredentialsConfig(
        accessKey: AwsConfig.accessKey,
        secretKey: AwsConfig.secretKey,
        bucketName: AwsConfig.bucketName,
        region: AwsConfig.region,
      ),
      lastScannedCode: lastCode,
      selectedDeliveryOption: deliveryOption,
      isQRCode: isQR,
      storeId: storeId,
    );
  }

  Future<void> _resetAfterUpload() async {
    await _cleanupControllers(); // Dọn dẹp controller
    _initializeScannerController(); // Khởi tạo lại scanner

    if (_cameras != null) {
      await initializeCamera(_cameras!); // Khởi tạo lại camera
    }

    state = state.copyWith(
      isRecording: false,
      isScanning: true,
      isInitialized: true, // Cập nhật lại trạng thái
      lastScannedCode: null,
      selectedDeliveryOption: null,
    );
  }

  Future<void> _cleanupControllers() async {
    try {
      if (_scannerController != null) {
        await _scannerController!.stop();
        await _scannerController!.dispose();
        _scannerController = null;
      }

      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      state = const RecordingState();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  Future<void> toggleFlash() async {
    if (state.isScanning) {
      await _scannerController?.toggleTorch();
      state = state.copyWith(isFlashOn: !state.isFlashOn);
    } else if (_cameraController != null) {
      try {
        final newFlashMode = state.isFlashOn ? FlashMode.off : FlashMode.torch;
        await _cameraController!.setFlashMode(newFlashMode);
        state = state.copyWith(isFlashOn: !state.isFlashOn);
      } catch (e) {
        debugPrint('Flash toggle error: $e');
      }
    }
  }

  void setDeliveryOption(String option) {
    state = state.copyWith(selectedDeliveryOption: option);
  }

  Future<void> handleBarcodeDetection(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null) return;

    try {
      debugPrint('Detected code: $code'); // Log để debug
      debugPrint('Current state: ${state.toString()}'); // Log state hiện tại

      if (state.isRecording) {
        if (code == STOP_CODE && _currentStoreId != null) {
          debugPrint(
              'STOP_CODE detected, stopping recording'); // Log khi phát hiện STOP_CODE
          await stopAndReset(_currentStoreId!);
        }
        return;
      }

      if (state.selectedDeliveryOption != null) {
        state = state.copyWith(
          lastScannedCode: code,
          isQRCode: barcode.format == BarcodeFormat.qrCode,
        );
        await startRecording();
      }
    } catch (e) {
      debugPrint('Barcode handling error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }

  CameraController? get cameraController => _cameraController;

  MobileScannerController? get scannerController => _scannerController;
}
