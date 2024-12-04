import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pjpacktrack/constants/helper.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/utils/validator.dart';
import 'package:pjpacktrack/widgets/common_appbar_view.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController mailcontroller = TextEditingController();
  String email = "";
  final _formkey = GlobalKey<FormState>();

  String _errorEmail = '';
  final TextEditingController _emailController = TextEditingController();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Email đặt lại mật khẩu đã được gửi !",
        style: TextStyle(fontSize: 18.0),
      )));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Không tìm thấy người dùng nào cho email đó.",
          style: TextStyle(fontSize: 18.0),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            appBar(),
            const SizedBox(
              height: 70.0,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: const Text(
                "Khôi phục mật khẩu",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Nhập email của bạn",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Form(
                    key: _formkey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black38, width: 2.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              controller: mailcontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return Loc.alized.enter_your_email;
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      color:
                                          Color.fromARGB(255, 156, 153, 153)),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Color.fromARGB(255, 121, 118, 118),
                                    size: 30.0,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = mailcontroller.text;
                                });
                                resetPassword();
                              }
                            },
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.lightGreen.shade700,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Text(
                                  "Gửi Email",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Không có tài khoản?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Tạo",
                                  style: TextStyle(
                                      color: Color.fromARGB(223, 20, 66, 28),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CommonAppbarView(
          iconData: Icons.arrow_back,
          //titleText: AppLocalizations(context).of("Password Recovery"),
          onBackClick: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
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
    setState(() {});
    return isValid;
  }
}
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   String _errorEmail = '';
//   final TextEditingController _emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RemoveFocuse(
//         onClick: () {
//           FocusScope.of(context).requestFocus(FocusNode());
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             appBar(),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 16.0, bottom: 16.0, left: 24, right: 24),
//                       child: Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: Text(
//                               Loc.alized.resend_email_link,
//                               textAlign: TextAlign.start,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Theme.of(context).disabledColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     CommonTextFieldView(
//                       controller: _emailController,
//                       titleText: Loc.alized.your_mail,
//                       errorText: _errorEmail,
//                       padding: const EdgeInsets.only(
//                           left: 24, right: 24, bottom: 24),
//                       hintText: Loc.alized.enter_your_email,
//                       keyboardType: TextInputType.emailAddress,
//                       onChanged: (String txt) {},
//                     ),
//                     CommonButton(
//                       padding: const EdgeInsets.only(
//                           left: 24, right: 24, bottom: 16),
//                       buttonText: Loc.alized.send,
//                       onTap: () {
//                         if (_allValidation()) Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget appBar() {
//     return CommonAppbarView(
//       iconData: Icons.arrow_back,
//       titleText: Loc.alized.forgot_your_password,
//       onBackClick: () {
//         Navigator.pop(context);
//       },
//     );
//   }

//   bool _allValidation() {
//     bool isValid = true;
//     if (_emailController.text.trim().isEmpty) {
//       _errorEmail = Loc.alized.email_cannot_empty;
//       isValid = false;
//     } else if (!Validator.validateEmail(_emailController.text.trim())) {
//       _errorEmail = Loc.alized.enter_valid_email;
//       isValid = false;
//     } else {
//       _errorEmail = '';
//     }
//     setState(() {});
//     return isValid;
//   }
// }
