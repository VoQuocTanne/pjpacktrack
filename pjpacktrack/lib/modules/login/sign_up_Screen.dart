import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pjpacktrack/constants/text_styles.dart';
import 'package:pjpacktrack/constants/themes.dart';
import 'package:pjpacktrack/future/authentication_bloc/authentication_bloc.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';
import 'package:pjpacktrack/modules/login/facebook_google_button_view.dart';
import 'package:pjpacktrack/routes/route_names.dart';
import 'package:pjpacktrack/utils/validator.dart';
import 'package:pjpacktrack/widgets/common_appbar_view.dart';
import 'package:pjpacktrack/widgets/common_button.dart';
import 'package:pjpacktrack/widgets/common_text_field_view.dart';
import 'package:pjpacktrack/widgets/dialog_widget.dart';
import 'package:pjpacktrack/widgets/remove_focuse.dart';
import '../../routes/routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _errorEmail = '';
  final TextEditingController _emailController = TextEditingController();
  String _errorPassword = '';
  final TextEditingController _passwordController = TextEditingController();
  String _errorFName = '';
  final TextEditingController _fnameController = TextEditingController();
  String _errorPNum = '';
  final TextEditingController _pnumController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is SignUpProcess) {
            // Hiển thị loading khi đang xử lý đăng ký
            LoadingDialog.show(context);
          } else if (state is SignUpFailure) {
            // Hiển thị thông báo lỗi nếu đăng ký thất bại
            Navigator.of(context).pop(); // Đóng loading dialog
            ErrorDialog.show(context, state.error);
          } else if (state is SignUpSuccess) {
            // Điều hướng đến TabScreen nếu đăng ký thành công
            Navigator.of(context).pop(); // Đóng loading dialog
            Navigator.pushNamed(context, RoutesName.home);
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
              _appBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: FacebookGoogleButtonView(),
                      ),
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
                        controller: _fnameController,
                        errorText: _errorFName,
                        padding: const EdgeInsets.only(
                            bottom: 16, left: 24, right: 24),
                        titleText: Loc.alized.full_name,
                        hintText: Loc.alized.enter_full_name,
                        keyboardType: TextInputType.name,
                        onChanged: (String txt) {},
                      ),
                      CommonTextFieldView(
                        controller: _pnumController,
                        errorText: _errorPNum,
                        padding: const EdgeInsets.only(
                            bottom: 16, left: 24, right: 24),
                        titleText: Loc.alized.phone,
                        hintText: Loc.alized.enter_phone,
                        keyboardType: TextInputType.name,
                        onChanged: (String txt) {},
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
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 24),
                        hintText: Loc.alized.enter_password,
                        isObscureText: true,
                        onChanged: (String txt) {},
                        errorText: _errorPassword,
                        controller: _passwordController,
                      ),
                      CommonButton(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 8),
                        buttonText: Loc.alized.sign_up,
                        onTap: () {
                          if (_allValidation()) {
                            final myUser = MyUser(
                                userId:
                                    '', // Hoặc để trống nếu không cần tại thời điểm này
                                email: _emailController.text.trim(),
                                fullname: _fnameController.text.trim(),
                                picture: null, // Nếu không có ảnh
                                phonenumber: _pnumController.text
                                    .trim(), // Nếu chưa có số điện thoại
                                birthday: DateTime
                                    .now(), // Nếu không có ngày sinh cụ thể
                                role: 'user', // Gán quyền mặc định
                                status: 'active',
                                quantily: 0,
                                packageId: 'I9DKf6eLpXDqtLnu5t0l');
                            setState(() {
                              context
                                  .read<AuthenticationBloc>()
                                  .add(SignUpRequired(
                                    myUser,
                                    _passwordController.text.trim(),
                                  ));
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          Loc.alized.terms_agreed,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            Loc.alized.already_have_account,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            onTap: () {
                              NavigationServices(context).gotoLoginScreen();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                Loc.alized.login,
                                style: TextStyles(context)
                                    .getRegularStyle()
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 24,
                      )
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

  Widget _appBar() {
    return CommonAppbarView(
      iconData: Icons.arrow_back,
      titleText: Loc.alized.sign_up,
      onBackClick: () {
        Navigator.pop(context);
      },
    );
  }

  bool _allValidation() {
    bool isValid = true;

    if (_fnameController.text.trim().isEmpty) {
      _errorFName = Loc.alized.full_name_cannot_empty;
      isValid = false;
    } else {
      _errorFName = '';
    }

    if (_pnumController.text.trim().isEmpty) {
      _errorPNum = Loc.alized.phone_cannot_empty;
      isValid = false;
    } else {
      _errorPNum = '';
    }

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
