// recording_controller.dart
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_repo/recording_state.dart';
import '../aws_config.dart';
import '../video/video_repo/video_upload_state.dart';
import '../video/video_upload_provider.dart';
import 'mk_kit_service.dart';

final recordingControllerProvider =
    StateNotifierProvider.autoDispose<RecordingController, RecordingState>(
        (ref) => RecordingController(ref));

class RecordingController extends StateNotifier<RecordingState> {
  final Ref ref;
  CameraController? _cameraController;
  MLKitService? _mlKitService;
  static const String STOP_CODE = "STOP";
  List<CameraDescription>? _cameras;
  String? _currentStoreId;
  late final VideoUploadNotifier _uploader;
  bool _isProcessing = false;

  RecordingController(this.ref) : super(const RecordingState()) {
    _uploader = ref.read(videoUploadProvider.notifier);
    _initializeMLKit();
  }

  // Step 1: Initialize camera
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
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processImageStream);
      state = state.copyWith(isInitialized: true);
      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Camera init error: $e');
      state = state.copyWith(isInitialized: false);
    }
  }

  Future<void> _initializeMLKit() async {
    _mlKitService = await MLKitService.create();
  }

  // Step 2: Set delivery option
  void setDeliveryOption(String option) {
    state = state.copyWith(
      selectedDeliveryOption: option,
      isScanning: true,
    );
  }

  // Step 3: Process camera stream for barcode detection
  Future<void> _processImageStream(CameraImage image) async {
    if (!state.isInitialized ||
        !state.isScanning ||
        _isProcessing ||
        _mlKitService == null ||
        state.selectedDeliveryOption == null) {
      return;
    }

    _isProcessing = true;

    try {
      final barcodes = await _mlKitService!.scanBarcodes(image);

      if (state.isRecording) {
        // During recording, process ML Kit results
        final labels = await _mlKitService!.labelImage(image);
        final objects = await _mlKitService!.detectObjects(image);

        state = state.copyWith(
          imageLabels: labels,
          detectedObjects: objects,
        );

        // Check for STOP code during recording
        if (barcodes.isNotEmpty &&
            barcodes.first.rawValue == STOP_CODE &&
            _currentStoreId != null) {
          await stopAndReset(_currentStoreId!);
        }
      } else if (barcodes.isNotEmpty && state.selectedDeliveryOption != null) {
        // Start recording when barcode is detected
        final barcode = barcodes.first;
        state = state.copyWith(
          lastScannedCode: barcode.rawValue,
          isQRCode: barcode.format == BarcodeFormat.qrCode,
        );
        await startRecording();
      }
    } catch (e) {
      debugPrint('ML Kit processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // Step 4: Start recording
  Future<void> startRecording() async {
    if (_cameraController != null &&
        !state.isRecording &&
        state.lastScannedCode != STOP_CODE) {
      try {
        await _cameraController!.startVideoRecording();
        state = state.copyWith(
          isRecording: true,
          isScanning: true,
        );
      } catch (e) {
        debugPrint('Recording start error: $e');
        rethrow;
      }
    }
  }

  // Step 5: Stop recording and reset
  Future<void> stopAndReset(String storeId) async {
    if (!state.isRecording || _cameraController == null) return;

    try {
      final videoFile = await _cameraController!.stopVideoRecording();

      // Upload video
      await _uploadVideo(
        videoFile,
        storeId,
        state.lastScannedCode!,
        state.selectedDeliveryOption!,
        state.isQRCode,
      );

      // Reset state
      state = state.copyWith(
        isRecording: false,
        isScanning: true,
        lastScannedCode: null,
        selectedDeliveryOption: null,
        imageLabels: [],
        detectedObjects: [],
      );
    } catch (e) {
      debugPrint('Stop recording error: $e');
      state = state.copyWith(isRecording: false);
      rethrow;
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

  Future<void> toggleFlash() async {
    if (_cameraController != null) {
      try {
        final newFlashMode = state.isFlashOn ? FlashMode.off : FlashMode.torch;
        await _cameraController!.setFlashMode(newFlashMode);
        state = state.copyWith(isFlashOn: !state.isFlashOn);
      } catch (e) {
        debugPrint('Flash toggle error: $e');
      }
    }
  }

  void setStoreId(String storeId) {
    _currentStoreId = storeId;
  }

  @override
  void dispose() async {
    await _mlKitService?.dispose();
    await _cameraController?.dispose();
    super.dispose();
  }

  CameraController? get cameraController => _cameraController;
}
