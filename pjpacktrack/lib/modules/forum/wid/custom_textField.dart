// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final int maxLines;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final Function(String)? onChanged;
//   final String? Function(String?)? validator;

//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     this.maxLines = 1,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.onChanged,
//     this.validator,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(color: Colors.grey),
//         filled: true,
//         fillColor: Colors.grey[100],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.deepPurple, width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//       maxLines: maxLines,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       onChanged: onChanged,
//       validator: validator,
//     );
//   }
// }