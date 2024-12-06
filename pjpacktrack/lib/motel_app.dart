import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pjpacktrack/common/common.dart';
import 'package:pjpacktrack/constants/themes.dart';
import 'package:pjpacktrack/future/authentication_bloc/authentication_bloc.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/logic/controllers/theme_provider.dart';
import 'package:pjpacktrack/main.dart';
import 'package:pjpacktrack/model/user_repo/firebase_user_repo.dart';
import 'package:pjpacktrack/model/user_repo/user_repo.dart';
import 'package:pjpacktrack/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:pjpacktrack/modules/login/login_screen.dart';
import 'package:pjpacktrack/modules/splash/introduction_screen.dart';
import 'package:pjpacktrack/modules/splash/splash_screen.dart';
import 'package:pjpacktrack/routes/routes.dart';

class MotelApp extends StatefulWidget {
  final UserRepository userRepository;
  const MotelApp(this.userRepository, {Key? key}) : super(key: key);

  @override
  State<MotelApp> createState() => _MotelAppState();
}

class _MotelAppState extends State<MotelApp> {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.userRepository,
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          userRepository: context.read<UserRepository>(),
        ),
        child: GetBuilder<Loc>(
          builder: (locController) {
            return GetBuilder<ThemeController>(
              builder: (controller) {
                final ThemeData theme = AppTheme.getThemeData;
                return GetMaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: const [
                    Locale('vi'), // VietNam
                    Locale('en'), // English
                    Locale('fr'), // French
                    Locale('ja'), // Japanises
                    Locale('ar'), // Arabic
                  ],
                  navigatorKey: navigatorKey,
                  locale: locController.locale,
                  title: 'Hotel',
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  routes: _buildRoutes(),
                  // initialBinding: AppBinding(),
                  builder: (BuildContext context, Widget? child) {
                    _setFirstTimeSomeData(context, theme);
                    return Directionality(
                      textDirection: locController.locale.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: MediaQuery(
                        key: ValueKey(
                            'languageCode ${locController.locale.languageCode}'),
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(
                              MediaQuery.of(context).size.width > 360
                                  ? 1.0
                                  : MediaQuery.of(context).size.width >= 340
                                      ? 0.9
                                      : 0.8),
                        ),
                        child: child ?? const SizedBox(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // when this application open every time on that time we check and update some theme data
  void _setFirstTimeSomeData(BuildContext context, ThemeData theme) {
    _setStatusBarNavigationBarTheme(theme);
    Get.find<ThemeController>()
        .checkAndSetThemeMode(MediaQuery.of(context).platformBrightness);
  }

  void _setStatusBarNavigationBarTheme(ThemeData themeData) {
    final brightness = !kIsWeb && Platform.isAndroid
        ? themeData.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light
        : themeData.brightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness,
      statusBarBrightness: brightness,
      systemNavigationBarColor: themeData.colorScheme.background,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: brightness,
    ));
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      RoutesName.splash: (BuildContext context) =>
          SplashScreen(cameras: cameras),
      RoutesName.introductionScreen: (BuildContext context) =>
          IntroductionScreen(FirebaseUserRepository()),
      RoutesName.home: (BuildContext context) =>
          BottomTabScreen(cameras: cameras),
      RoutesName.login: (BuildContext context) => const LoginScreen(),
    };
  }
}
