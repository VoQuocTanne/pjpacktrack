import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tạo FutureProvider để lấy dữ liệu người dùng từ Firebase
final userDataProvider = FutureProvider<Map<String, String>>((ref) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Người dùng chưa đăng nhập');
  }

  final DatabaseReference userRef =
      FirebaseDatabase.instance.ref().child('users').child(user.uid);
  DataSnapshot snapshot = await userRef.get();

  if (snapshot.value == null) {
    throw Exception('Dữ liệu người dùng không tồn tại');
  }

  if (snapshot.value is Map) {
    Map<dynamic, dynamic> userMap = snapshot.value as Map<dynamic, dynamic>;
    return {
      'name': userMap['name'] ?? 'Chưa có tên',
      'phone': userMap['phone'] ?? 'Chưa có số điện thoại',
      'email': userMap['email'] ?? 'Chưa có email',
    };
  } else {
    throw Exception('Dữ liệu không đúng định dạng');
  }
});

class MyAccountScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tài Khoản Của Tôi"),
      ),
      body: ref.watch(userDataProvider).when(
            data: (userData) {
              return Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('Họ và tên', userData['name']!),
                    _buildInfoItem('Số điện thoại', userData['phone']!),
                    _buildInfoItem('Email', userData['email']!),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
          ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
