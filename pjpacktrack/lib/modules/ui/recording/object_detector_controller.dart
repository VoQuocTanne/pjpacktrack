// object_detector_controller.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'image_processor.dart';

class ObjectDetectorController {
  ObjectDetector? _objectDetector;
  ImageProcessor? _imageProcessor;
  bool _isBusy = false;
  List<DetectedObject> _detectedObjects = [];

  // Frame processing rate control
  DateTime? _lastProcessingTime;
  static const Duration _minimumProcessingInterval = Duration(milliseconds: 100);

  Future<void> initializeDetector() async {
    // Initialize image processor
    _imageProcessor = ImageProcessor();
    await _imageProcessor?.initialize();

    // Get model path
    final path = await _getModel('model.tflite');

    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: path,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.5, // Adjust based on your needs
    );

    _objectDetector = ObjectDetector(options: options);
  }

  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = join((await getApplicationSupportDirectory()).path, assetPath);
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  bool _shouldProcessFrame() {
    if (_lastProcessingTime == null) return true;

    final now = DateTime.now();
    if (now.difference(_lastProcessingTime!) >= _minimumProcessingInterval) {
      _lastProcessingTime = now;
      return true;
    }
    return false;
  }

  Future<void> processImage(CameraImage image) async {
    if (_isBusy || !_shouldProcessFrame()) return;
    _isBusy = true;

    try {
      // Process image in isolate
      final processedImage = await _imageProcessor?.processImage(image);
      if (processedImage == null) return;

      // Detect objects
      final objects = await _objectDetector?.processImage(processedImage) ?? [];

      // Filter objects based on confidence
      _detectedObjects = objects.where((obj) {
        final highestConfidence = obj.labels.fold<double>(
          0.0,
              (prev, label) => label.confidence > prev ? label.confidence : prev,
        );
        return highestConfidence >= 0.5; // Minimum confidence threshold
      }).toList();

      // Sort objects by confidence
      _detectedObjects.sort((a, b) {
        final aConf = a.labels.first.confidence;
        final bConf = b.labels.first.confidence;
        return bConf.compareTo(aConf);
      });

      // Limit to top N objects if needed
      if (_detectedObjects.length > 5) {
        _detectedObjects = _detectedObjects.sublist(0, 5);
      }

    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isBusy = false;
    }
  }

  List<DetectedObjectInfo> getDetectedObjectsInfo() {
    return _detectedObjects.map((obj) {
      final label = obj.labels.first;
      return DetectedObjectInfo(
        label: label.text,
        confidence: label.confidence,
        boundingBox: obj.boundingBox,
      );
    }).toList();
  }

  void dispose() {
    _objectDetector?.close();
    _imageProcessor?.dispose();
  }
}

class DetectedObjectInfo {
  final String label;
  final double confidence;
  final Rect boundingBox;

  DetectedObjectInfo({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
}