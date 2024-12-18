// ml_kit_service.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class MLKitService {
  final BarcodeScanner _barcodeScanner;
  final ImageLabeler _imageLabeler;
  final ObjectDetector _objectDetector;

  MLKitService._({
    required BarcodeScanner barcodeScanner,
    required ImageLabeler imageLabeler,
    required ObjectDetector objectDetector,
  }) : _barcodeScanner = barcodeScanner,
        _imageLabeler = imageLabeler,
        _objectDetector = objectDetector;

  static Future<MLKitService> create() async {
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.7),
    );

    final modelPath = await _getModel('object_labeler.tflite');
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.single,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    final objectDetector = ObjectDetector(options: options);

    return MLKitService._(
      barcodeScanner: barcodeScanner,
      imageLabeler: imageLabeler,
      objectDetector: objectDetector,
    );
  }

  static Future<String> _getModel(String modelName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = join(appDir.path, modelName);
    final file = io.File(modelPath);

    if (!await file.exists()) {
      final byteData = await rootBundle.load('assets/ml/$modelName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return modelPath;
  }

  Future<List<Barcode>> scanBarcodes(CameraImage image) async {
    try {
      final inputImage = _processImageToInput(image);
      if (inputImage != null) {
        return await _barcodeScanner.processImage(inputImage);
      }
      return [];
    } catch (e) {
      print('Error processing barcode: $e');
      return [];
    }
  }

  Future<List<ImageLabel>> labelImage(CameraImage image) async {
    try {
      final inputImage = _processImageToInput(image);
      if (inputImage != null) {
        return await _imageLabeler.processImage(inputImage);
      }
      return [];
    } catch (e) {
      print('Error processing labels: $e');
      return [];
    }
  }

  Future<List<DetectedObject>> detectObjects(CameraImage image) async {
    try {
      final inputImage = _processImageToInput(image);
      if (inputImage != null) {
        return await _objectDetector.processImage(inputImage);
      }
      return [];
    } catch (e) {
      print('Error detecting objects: $e');
      return [];
    }
  }

  InputImage? _processImageToInput(CameraImage image) {
    try {
      final yBuffer = image.planes[0].bytes;
      final uBuffer = image.planes[1].bytes;
      final vBuffer = image.planes[2].bytes;

      final int yLength = yBuffer.length;
      final int uLength = uBuffer.length;
      final int vLength = vBuffer.length;

      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final buffer = Uint8List(yLength + uLength + vLength);

      // Add Y plane
      buffer.setRange(0, yLength, yBuffer);

      // Add U and V planes
      int uvIndex = yLength;
      int uvByteIndex = 0;
      for (int y = 0; y < height ~/ 2; y++) {
        for (int x = 0; x < width ~/ 2; x++) {
          final int bufferIndex = uvIndex + y * width + x * 2;
          buffer[bufferIndex] = uBuffer[uvByteIndex];
          buffer[bufferIndex + 1] = vBuffer[uvByteIndex];
          uvByteIndex += uvPixelStride;
        }
        if (uvByteIndex % uvRowStride != 0) {
          uvByteIndex += uvRowStride - (uvByteIndex % uvRowStride);
        }
      }

      return InputImage.fromBytes(
        bytes: buffer,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.width,
        ),
      );
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    await _barcodeScanner.close();
    await _imageLabeler.close();
    await _objectDetector.close();
  }
}