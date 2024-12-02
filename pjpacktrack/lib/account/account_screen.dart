// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pjpacktrack/account/change_password.dart';
// import 'package:pjpacktrack/account/my_account_screen.dart';
// import 'package:pjpacktrack/auth/login.dart';
// import 'package:pjpacktrack/ui/QRScannerAndVideo.dart';

// class AccountScreen extends StatelessWidget {
  
//   // Hàm đăng xuất
//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi: Không thể đăng xuất!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildListItem(
//               Icons.person,
//               'Tài khoản của tôi',
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MyAccountScreen()),
//               ),
//             ),
//             _buildListItem(Icons.security, 'Gói bản quyền'),
//             _buildListItem(Icons.shopping_cart, 'Lịch sử cập nhật'),
//             _buildListItem(Icons.language, 'Ngôn ngữ'),
//             _buildListItem(
//               Icons.password,
//               'Đổi mật khẩu',
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
//               ),
//             ),
//             _buildListItem(
//               Icons.logout,
//               'Đăng xuất',
//               () => _signOut(context), // Gọi hàm đăng xuất
//             ),
//             Spacer(),
//           ],
//         ),
//       ),
      
//         Get.offAll(QRScannerAndVideo(
//           cameras: cameras,
//         ));
//       bottomNavigationBar: QRScannerAndVideo(cameras: [],),
//     );
//   }

//   Widget _buildListItem(IconData icon, String label, [Function()? onTap]) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 12.0),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//           decoration: BoxDecoration(
//             color: Colors.white, // Màu nền bên trong
//             borderRadius: BorderRadius.circular(8.0), // Góc bo tròn
//             border: Border.all(color: Colors.grey[300]!, width: 1), // Viền xám
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 24.0,
//                 color: Colors.grey[600],
//               ),
//               SizedBox(width: 16.0),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 16.0,
//                 ),
//               ),
//               Spacer(),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 size: 18.0,
//                 color: Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
