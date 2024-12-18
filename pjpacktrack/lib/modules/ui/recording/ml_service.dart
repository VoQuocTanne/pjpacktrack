// ml_service.dart
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class MLService {
  // ML Kit detectors
  late final ObjectDetector _objectDetector;
  late final ImageLabeler _imageLabeler;
  late final BarcodeScanner _barcodeScanner;

  bool _isBusy = false;
  DateTime? _lastProcessingTime;
  static const Duration _minimumProcessingInterval = Duration(milliseconds: 100);

  // Detection results
  List<DetectedObject> _detectedObjects = [];
  List<ImageLabel> _imageLabels = [];
  List<Barcode> _barcodes = [];

  Future<void> initialize() async {
    // Initialize object detector
    final modelPath = await _getModel('model.tflite');
    final objectOptions = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.5,
    );
    _objectDetector = ObjectDetector(options: objectOptions);

    // Initialize image labeler
    final labelerOptions = ImageLabelerOptions(
      confidenceThreshold: 0.7,
      maxResults: 5,
    );
    _imageLabeler = ImageLabeler(options: labelerOptions);

    // Initialize barcode scanner
    final barcodeOptions = BarcodeScanner(
      formats: [BarcodeFormat.all],
    );
    _barcodeScanner = barcodeOptions;
  }

  Future<MLDetectionResult?> processFrame(CameraImage image) async {
    if (_isBusy || !_shouldProcessFrame()) return null;
    _isBusy = true;

    try {
      final inputImage = await _prepareInputImage(image);
      if (inputImage == null) return null;

      // Run detections in parallel
      final results = await Future.wait([
        _objectDetector.processImage(inputImage),
        _imageLabeler.processImage(inputImage),
        _barcodeScanner.processImage(inputImage),
      ]);

      _detectedObjects = results[0] as List<DetectedObject>;
      _imageLabels = results[1] as List<ImageLabel>;
      _barcodes = results[2] as List<Barcode>;

      // Process and combine results
      return MLDetectionResult(
        objects: _processDetectedObjects(_detectedObjects),
        labels: _processImageLabels(_imageLabels),
        barcodes: _processBarcodes(_barcodes),
      );

    } catch (e) {
      debugPrint('ML Processing error: $e');
      return null;
    } finally {
      _isBusy = false;
    }
  }

  List<DetectedObjectInfo> _processDetectedObjects(List<DetectedObject> objects) {
    return objects
        .where((obj) => obj.labels.isNotEmpty &&
        obj.labels.first.confidence >= 0.5)
        .map((obj) {
      final label = obj.labels.first;
      return DetectedObjectInfo(
        label: label.text,
        confidence: label.confidence,
        boundingBox: obj.boundingBox,
        trackingId: obj.trackingId,
      );
    })
        .toList();
  }

  List<LabelInfo> _processImageLabels(List<ImageLabel> labels) {
    return labels
        .where((label) => label.confidence >= 0.7)
        .map((label) => LabelInfo(
      text: label.label,
      confidence: label.confidence,
      index: label.index,
    ))
        .toList();
  }

  List<BarcodeInfo> _processBarcodes(List<Barcode> barcodes) {
    return barcodes
        .map((barcode) => BarcodeInfo(
      value: barcode.rawValue ?? '',
      format: barcode.format,
      boundingBox: barcode.boundingBox,
      corners: barcode.corners,
    ))
        .toList();
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

  Future<InputImage?> _prepareInputImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageMetadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.bgra8888,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: imageMetadata,
    );
  }

  void dispose() {
    _objectDetector.close();
    _imageLabeler.close();
    _barcodeScanner.close();
  }
}

// Result models
class MLDetectionResult {
  final List<DetectedObjectInfo> objects;
  final List<LabelInfo> labels;
  final List<BarcodeInfo> barcodes;

  MLDetectionResult({
    required this.objects,
    required this.labels,
    required this.barcodes,
  });
}

class DetectedObjectInfo {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final int? trackingId;

  DetectedObjectInfo({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.trackingId,
  });
}

class LabelInfo {
  final String text;
  final double confidence;
  final int index;

  LabelInfo({
    required this.text,
    required this.confidence,
    required this.index,
  });
}

class BarcodeInfo {
  final String value;
  final BarcodeFormat format;
  final Rect? boundingBox;
  final List<Point<int>>? corners;

  BarcodeInfo({
    required this.value,
    required this.format,
    this.boundingBox,
    this.corners,
  });
}