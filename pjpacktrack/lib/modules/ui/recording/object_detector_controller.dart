import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ObjectDetectorController {
  ObjectDetector? _objectDetector;
  bool _isBusy = false;
  List<DetectedObject> _detectedObjects = [];

  Future<void> initializeDetector() async {
    // Get application documents directory
    final path = await _getModel('model.tflite');

    final modelPath = path;
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
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

  Future<void> processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotation.rotation0deg;
    final inputImageFormat = InputImageFormat.bgra8888;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );

    try {
      _detectedObjects = await _objectDetector?.processImage(inputImage) ?? [];
    } catch (e) {
      debugPrint('Error processing image: $e');
    }

    _isBusy = false;
  }

  List<DetectedObject> get detectedObjects => _detectedObjects;

  void dispose() {
    _objectDetector?.close();
  }
}