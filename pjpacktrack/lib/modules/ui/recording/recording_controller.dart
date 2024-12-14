import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_repo/recording_state.dart';
import '../aws_config.dart';
import '../video/video_upload_provider.dart';

final recordingControllerProvider =
    StateNotifierProvider.autoDispose<RecordingController, RecordingState>(
        (ref) {
  return RecordingController(ref);
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

  RecordingController(this.ref) : super(const RecordingState()) {
    _initializeScannerController();
  }

  void _initializeScannerController() {
    _scannerController?.dispose();

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.qrCode],
      returnImage: false,
    );
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
      state = state.copyWith(isInitialized: true); // Cập nhật state
      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Camera init error: $e');
      state = state.copyWith(isInitialized: false);
    }
  }

  void setStoreId(String storeId) {
    _currentStoreId = storeId;
  }

  Future<void> startRecording() async {
    if (_cameraController != null && !state.isRecording && state.isQRCode != STOP_CODE) {
      try {
        await _cameraController!.startVideoRecording();
        state = state.copyWith(
          isRecording: true,
          isScanning: true, // Giữ scanning mode bật
        );
      } catch (e) {
        debugPrint('Recording start error: $e');
        rethrow;
      }
    }
  }

  Future<void> stopAndReset(String storeId) async {
    if (_cameraController == null || !state.isRecording) {
      return;
    }

    try {
      if (!_cameraController!.value.isRecordingVideo) {
        debugPrint('No video is recording, skip stopping recording');
        return;
      }
      // Lấy video uploader và config
      final videoUploader = ref.read(videoUploadProvider.notifier);
      final credentialsConfig = AwsCredentialsConfig(
        accessKey: AwsConfig.accessKey,
        secretKey: AwsConfig.secretKey,
        bucketName: AwsConfig.bucketName,
        region: AwsConfig.region,
      );

      // Stop recording
      final XFile videoFile = await _cameraController!.stopVideoRecording();

      // Lưu state
      final lastCode = state.lastScannedCode;
      final deliveryOption = state.selectedDeliveryOption;
      final isQR = state.isQRCode;

      debugPrint('Starting video upload...');

      // Upload video
      await videoUploader.uploadVideo(
        filePath: videoFile.path,
        credentialsConfig: credentialsConfig,
        lastScannedCode: lastCode!,
        selectedDeliveryOption: deliveryOption!,
        isQRCode: isQR,
        storeId: storeId,
      );
      debugPrint('Upload completed');

      await _cleanupControllers();
      _initializeScannerController();
      await _scannerController?.start();

      state = state.copyWith(
        isRecording: false,
        isScanning: true,
        lastScannedCode: null,
      );
    } catch (e) {
      debugPrint('Error during stop & upload: $e');

      state = state.copyWith(
        isRecording: false,
        isScanning: true,
        lastScannedCode: null,
      );

      rethrow;
    }
  }

  Future<void> _cleanupControllers() async {
    try {
      // Dispose camera controller
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      if (_scannerController != null) {
        await _scannerController!.dispose();
        _scannerController = null;
      }

      // Reset state
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
      if (state.isRecording) {
        if (code == STOP_CODE && _currentStoreId != null) {
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
