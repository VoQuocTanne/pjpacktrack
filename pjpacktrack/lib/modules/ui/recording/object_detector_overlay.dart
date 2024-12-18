// object_detector_overlay.dart
import 'package:flutter/material.dart';

import 'object_detector_controller.dart';

class ObjectDetectorOverlay extends StatelessWidget {
  final List<DetectedObjectInfo> detectedObjects;
  final Size screenSize;

  const ObjectDetectorOverlay({
    Key? key,
    required this.detectedObjects,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Draw bounding boxes
        CustomPaint(
          size: screenSize,
          painter: BoundingBoxPainter(
            detectedObjects: detectedObjects,
            screenSize: screenSize,
          ),
        ),

        // Draw labels
        ...detectedObjects.map((obj) => Positioned(
          left: obj.boundingBox.left,
          top: obj.boundingBox.top - 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${obj.label} ${(obj.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),

        // Object list panel
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(maxWidth: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detected Objects:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...detectedObjects.map((obj) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(obj.confidence),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${obj.label} (${(obj.confidence * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<DetectedObjectInfo> detectedObjects;
  final Size screenSize;

  BoundingBoxPainter({
    required this.detectedObjects,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (final obj in detectedObjects) {
      final rect = obj.boundingBox;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return oldDelegate.detectedObjects != detectedObjects;
  }
}