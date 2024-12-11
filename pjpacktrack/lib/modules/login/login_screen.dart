import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pjpacktrack/future/authentication_bloc/authentication_bloc.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/modules/store/list_store_screen.dart';
import 'package:pjpacktrack/routes/route_names.dart';
import 'package:pjpacktrack/utils/validator.dart';
import 'package:pjpacktrack/widgets/common_appbar_view.dart';
import 'package:pjpacktrack/widgets/common_button.dart';
import 'package:pjpacktrack/widgets/common_text_field_view.dart';
import 'package:pjpacktrack/widgets/remove_focuse.dart';

import '../../routes/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _errorEmail = '';
  final TextEditingController _emailController = TextEditingController();
  String _errorPassword = '';
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) async {
          if (state is SignInFailure) {
            // Hiển thị lỗi khi đăng nhập thất bại
            // ErrorDialog.show(context, state.error);
          } else if (state is AuthenticationStateAuthenticated) {
            // Lấy user hiện tại từ Firebase
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              try {
                // Truy cập Firestore để lấy dữ liệu user
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                if (userDoc.exists) {
                  // Lấy role và status từ dữ liệu user
                  final role = userDoc.data()?['role'] ?? 'user';
                  final status = userDoc.data()?['status'] ?? 'active';

                  if (status != 'active') {
                    // Hiển thị thông báo trạng thái tài khoản không hợp lệ
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Tài khoản bị tạm ngưng'),
                            content: const Text(
                              'Tài khoản của bạn đã bị khóa hoặc tạm ngưng. Vui lòng liên hệ bộ phận hỗ trợ để biết thêm chi tiết.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Đăng xuất người dùng
                                  context
                                      .read<AuthenticationBloc>()
                                      .add(SignOutRequired());
                                  Navigator.of(context).pop(); // Đóng Dialog
                                  NavigationServices(context).gotoLoginScreen();
                                },
                                child: const Text('Thoát'),
                              ),
                            ],
                          );
                        },
                      );
                    });

                    // Ngăn các widget tiếp tục xây dựng khi tài khoản không hợp lệ
                    SizedBox();
                  } else {
                    // Điều hướng đến trang StoreListScreen thay vì các trang khác
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreListScreen(uid: user.uid),
                      ),
                    );
                  }

                  // else if (role == 'admin') {
                  //   // Điều hướng đến trang Admin nếu role là admin
                  //   Navigator.pushNamed(context, '/admin/dashboard');
                  // } else if (role == 'user') {
                  //   // Điều hướng đến trang chủ nếu role là user
                  //   Navigator.pushNamed(context, RoutesName.home);
                  // } else if (role == 'owner') {
                  //   // Điều hướng đến trang chủ nếu role là user
                  //   Navigator.pushNamed(context, RoutesName.owner);
                  // } else {
                  //   // Trường hợp không xác định vai trò
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //         content: Text('Vai trò của bạn không hợp lệ')),
                  //   );
                  // }
                } else {
                  // Nếu không tìm thấy user trong Firestore
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Người dùng không tồn tại trong hệ thống'),
                    ),
                  );
                }
              } catch (e) {
                // Xử lý lỗi khi truy cập Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xảy ra lỗi: $e'),
                  ),
                );
              }
            } else {
              // Nếu user chưa đăng nhập
              Navigator.pushNamed(context, RoutesName.login);
            }
          }
        },
        child: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CommonAppbarView(
                iconData: Icons.arrow_back,
                titleText: Loc.alized.login,
                onBackClick: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // const Padding(
                      //   padding: EdgeInsets.only(top: 32),
                      //   child: FacebookGoogleButtonView(),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          Loc.alized.log_with_mail,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      CommonTextFieldView(
                        controller: _emailController,
                        errorText: _errorEmail,
                        titleText: Loc.alized.your_mail,
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 16),
                        hintText: Loc.alized.enter_your_email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String txt) {},
                      ),
                      CommonTextFieldView(
                        titleText: Loc.alized.password,
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        hintText: Loc.alized.enter_password,
                        isObscureText: true,
                        onChanged: (String txt) {},
                        errorText: _errorPassword,
                        controller: _passwordController,
                      ),
                      _forgotYourPasswordUI(),
                      CommonButton(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 16),
                        buttonText: Loc.alized.login,
                        onTap: () {
                          if (_allValidation()) {
                            // Phát sự kiện đăng nhập khi form hợp lệ
                            context.read<AuthenticationBloc>().add(
                                  SignInRequired(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _forgotYourPasswordUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () {
              NavigationServices(context).gotoForgotPassword();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Loc.alized.forgot_your_password,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _navigateBasedOnRole(BuildContext context, String route) async {
  //   final user = FirebaseAuth.instance.currentUser;

  //   if (user != null) {
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();

  //     if (userDoc.exists) {
  //       final role = userDoc['role'];

  //       if (role == 'admin' && route == '/admin/dashboard') {
  //         Navigator.pushNamed(context, route);
  //       } else if (role == 'users' && route == RoutesName.home) {
  //         Navigator.pushNamed(context, route);
  //       } else {
  //         print('Unauthorized access!');
  //         // Redirect hoặc hiển thị lỗi truy cập
  //       }
  //     }
  //   } else {
  //     Navigator.pushNamed(context, RoutesName.login);
  //   }
  // }

  void _checkUserRole(BuildContext context, String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final role = userDoc['role'];

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else if (role == 'users') {
        Navigator.pushReplacementNamed(context, RoutesName.home);
      } else {
        // Xử lý role không xác định
        print('Role không hợp lệ!');
      }
    } else {
      print('Tài khoản không tồn tại trong Firestore.');
    }
  }

  bool _allValidation() {
    bool isValid = true;
    if (_emailController.text.trim().isEmpty) {
      _errorEmail = Loc.alized.email_cannot_empty;
      isValid = false;
    } else if (!Validator.validateEmail(_emailController.text.trim())) {
      _errorEmail = Loc.alized.enter_valid_email;
      isValid = false;
    } else {
      _errorEmail = '';
    }

    if (_passwordController.text.trim().isEmpty) {
      _errorPassword = Loc.alized.password_cannot_empty;
      isValid = false;
    } else if (_passwordController.text.trim().length < 6) {
      _errorPassword = Loc.alized.valid_password;
      isValid = false;
    } else {
      _errorPassword = '';
    }
    setState(() {});
    return isValid;
  }
}
