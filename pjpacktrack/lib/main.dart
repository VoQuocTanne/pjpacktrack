import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/instance_manager.dart';
import 'package:pjpacktrack/firebase_options.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/logic/controllers/theme_provider.dart';
import 'package:pjpacktrack/model/user_repo/firebase_user_repo.dart';
import 'package:pjpacktrack/motel_app.dart';
import 'package:pjpacktrack/widgets/app_constant.dart';

late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    Stripe.publishableKey = publishableKey;
  }
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Get.putAsync<Loc>(() => Loc().init(), permanent: true);

  await Get.putAsync<ThemeController>(() => ThemeController.init(),
      permanent: true);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(ProviderScope(
      child: MotelApp(FirebaseUserRepository())))); // Thêm ProviderScope ở đây
}
