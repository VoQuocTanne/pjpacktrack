import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectorPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size absoluteImageSize;

  ObjectDetectorPainter(this.objects, this.absoluteImageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / absoluteImageSize.width;
    final scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    for (final DetectedObject object in objects) {
      // Scale the bounding box to match the screen size
      final scaledRect = Rect.fromLTRB(
        object.boundingBox.left * scaleX,
        object.boundingBox.top * scaleY,
        object.boundingBox.right * scaleX,
        object.boundingBox.bottom * scaleY,
      );

      canvas.drawRect(scaledRect, paint);

      // Add label with confidence score
      final labels = object.labels
          .where((label) => label.confidence > 0.7)
          .map(
              (label) => '${label.text} (${(label.confidence * 100).toInt()}%)')
          .join(", ");

      if (labels.isNotEmpty) {
        TextSpan span = TextSpan(
          text: labels,
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            backgroundColor: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        );

        TextPainter tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          scaledRect.topLeft.translate(0, -tp.height),
        );
      }
    }
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.objects != objects;
  }
}
