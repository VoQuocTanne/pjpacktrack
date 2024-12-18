// image_processor.dart
import 'dart:isolate';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  static const int _targetWidth = 640;  // Adjust based on your model's requirements
  static const int _targetHeight = 480;  // Adjust based on your model's requirements

  // Isolate for image processing
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  Future<void> initialize() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _processImageIsolate,
      _receivePort!.sendPort,
    );
    _sendPort = await _receivePort!.first;
  }

  static void _processImageIsolate(SendPort sendPort) {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is _ImageProcessingMessage) {
        final processedImage = _processImageSync(
          message.planes,
          message.width,
          message.height,
        );
        message.responsePort.send(processedImage);
      }
    });
  }

  static InputImage _processImageSync(
      List<Plane> planes,
      int width,
      int height,
      ) {
    // Create a buffer for the image data
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    // Convert to RGB format
    final img.Image? image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      order: img.ChannelOrder.bgra,
    );

    if (image == null) throw Exception('Failed to create image from bytes');

    // Resize image if needed
    final img.Image resizedImage = img.copyResize(
      image,
      width: _targetWidth,
      height: _targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // Convert back to bytes
    final processedBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);

    // Create InputImage
    return InputImage.fromBytes(
      bytes: processedBytes,
      metadata: InputImageMetadata(
        size: Size(_targetWidth.toDouble(), _targetHeight.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: _targetWidth * 4,
      ),
    );
  }

  Future<InputImage?> processImage(CameraImage image) async {
    if (_sendPort == null) return null;

    final ReceivePort responsePort = ReceivePort();
    _sendPort!.send(_ImageProcessingMessage(
      planes: image.planes,
      width: image.width,
      height: image.height,
      responsePort: responsePort.sendPort,
    ));

    final result = await responsePort.first;
    return result as InputImage?;
  }

  void dispose() {
    _isolate?.kill();
    _receivePort?.close();
  }
}

class _ImageProcessingMessage {
  final List<Plane> planes;
  final int width;
  final int height;
  final SendPort responsePort;

  _ImageProcessingMessage({
    required this.planes,
    required this.width,
    required this.height,
    required this.responsePort,
  });
}