import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BrightnessPreview extends StatelessWidget {
  final Widget child;
  final Function(double) onBrightnessChanged;

  const BrightnessPreview({
    required this.child,
    required this.onBrightnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          child,
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.transparent,
              BlendMode.saturation,
            ),
            child: Container(
              width: 1,
              height: 1,
              color: Colors.transparent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  onBrightnessChanged(_calculateBrightness(constraints));
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBrightness(BoxConstraints constraints) {
    // Tính toán độ sáng dựa trên màu và kích thước
    return constraints.maxWidth * constraints.maxHeight / 255;
  }
}