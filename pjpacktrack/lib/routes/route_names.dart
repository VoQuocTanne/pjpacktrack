import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';
import 'package:pjpacktrack/modules/forum/screens/post_list_screen.dart';
import 'package:pjpacktrack/modules/login/change_password.dart';
import 'package:pjpacktrack/modules/login/forgot_password.dart';
import 'package:pjpacktrack/modules/login/login_screen.dart';
import 'package:pjpacktrack/modules/login/sign_up_Screen.dart';
import 'package:pjpacktrack/modules/profile/country_screen.dart';
import 'package:pjpacktrack/modules/profile/currency_screen.dart';
import 'package:pjpacktrack/modules/profile/edit_profile.dart';
import 'package:pjpacktrack/modules/profile/hepl_center_screen.dart';
import 'package:pjpacktrack/modules/profile/how_do_screen.dart';
import 'package:pjpacktrack/modules/profile/package_screen.dart';
import 'package:pjpacktrack/modules/profile/settings_screen.dart';
import 'package:pjpacktrack/modules/profile/web_view.dart';
import 'package:pjpacktrack/modules/store/list_store_screen.dart';
import 'package:pjpacktrack/routes/routes.dart';

class NavigationServices {
  NavigationServices(this.context);

  final BuildContext context;

  Future<dynamic> _pushMaterialPageRoute(Widget widget,
      {bool fullscreenDialog = false}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => widget, fullscreenDialog: fullscreenDialog),
    );
  }

  // Future gotoSplashScreen() async {
  //   await Navigator.pushNamedAndRemoveUntil(
  //       context, RoutesName.splash, (Route<dynamic> route) => false);
  // }

  void gotoIntroductionScreen() {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.introductionScreen,
        (Route<dynamic> route) => false);
  }

  Future<dynamic> gotoLoginScreen() async {
    return await _pushMaterialPageRoute(const LoginScreen());
  }

  // Future<dynamic> gotoTabScreen() async {
  //   return await _pushMaterialPageRoute(const BottomTabScreen());
  // }

  // Future<dynamic> gotoTabScreenAndClearStack() async {
  //   return Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const BottomTabScreen()),
  //     (route) => false, // Xóa toàn bộ ngăn xếp
  //   );
  // }

  Future<dynamic> gotoSignScreen() async {
    return await _pushMaterialPageRoute(const SignUpScreen());
  }

  Future<dynamic> gotoServicePackageScreen() async {
    return await _pushMaterialPageRoute(ServicePackageScreen());
  }

  Future<dynamic> gotoForgotPassword() async {
    return await _pushMaterialPageRoute(const ForgotPasswordScreen());
  }

  Future<dynamic> gotoHowDoScreen() async {
    return await _pushMaterialPageRoute(const HowDoScreen());
  }

  Future<dynamic> gotoSettingsScreen() async {
    return await _pushMaterialPageRoute(const SettingsScreen());
  }

  Future<dynamic> gotoHeplCenterScreen() async {
    return await _pushMaterialPageRoute(const HeplCenterScreen());
  }

  Future<dynamic> gotoChangepasswordScreen() async {
    return await _pushMaterialPageRoute(const ChangepasswordScreen());
  }

  Future<dynamic> gotoEditProfile(MyUser myUser) async {
    return await _pushMaterialPageRoute(EditProfile(myUser: myUser));
  }

  Future<dynamic> gotoCurrencyScreen() async {
    return await _pushMaterialPageRoute(const CurrencyScreen(),
        fullscreenDialog: true);
  }

  Future<dynamic> gotoCountryScreen() async {
    return await _pushMaterialPageRoute(const CountryScreen(),
        fullscreenDialog: true);
  }

  Future<dynamic> gotoViewWeb(String url) async {
    return await _pushMaterialPageRoute(WebView(
      url: url,
    ));
  }

  // Future<dynamic> gotoStoreScreen(String uid) async {
  //   return await _pushMaterialPageRoute(StoreListScreen(uid: uid),
  //       fullscreenDialog: true);
  // }
}
