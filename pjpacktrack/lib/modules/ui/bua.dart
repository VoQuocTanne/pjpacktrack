// Thêm class này vào RecordingScreen.dart
import 'package:camera/camera.dart';

class BrightnessAnalyzer {
  static double analyzeImageBrightness(CameraImage image) {
    final List<int> luminances = image.planes[0].bytes;
    double totalBrightness = 0;

    for (int i = 0; i < luminances.length; i++) {
      totalBrightness += luminances[i];
    }

    return totalBrightness / luminances.length;
  }

  static String getBrightnessWarning(double brightness) {
    if (brightness < 85) return "Ánh sáng quá yếu";
    if (brightness > 200) return "Ánh sáng quá mạnh";
    return "";
  }
}



