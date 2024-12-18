// object_detector_overlay.dart
import 'package:flutter/material.dart';

class ObjectDetectorOverlay extends StatelessWidget {
  final List<String> detectedObjects;

  const ObjectDetectorOverlay({
    Key? key,
    required this.detectedObjects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detectedObjects.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detected Objects:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...detectedObjects.map((object) => Text(
              object,
              style: const TextStyle(color: Colors.white),
            )),
          ],
        ),
      ),
    );
  }
}