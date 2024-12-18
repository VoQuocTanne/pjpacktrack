import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String userId;
  final String email;
  final String fullname;
  final String? picture;
  final String phonenumber;
  final DateTime birthday;
  final String role;
  final String status;
  final int limit;
  final String packageId; // Thêm trường packageId
  final int quantily; // Thêm trường quantily

  const MyUserEntity({
    required this.userId,
    required this.email,
    required this.fullname,
    this.picture,
    required this.phonenumber,
    required this.birthday,
    required this.role,
    required this.status,
    required this.limit,
    required this.packageId, // Bắt buộc trường packageId
    required this.quantily, // Bắt buộc trường quantily
  });

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'fullname': fullname,
      'picture': picture,
      'phonenumber': phonenumber,
      'birthday': Timestamp.fromDate(birthday), // Chuyển DateTime thành Timestamp
      'role': role,
      'status': status,
      'limit': limit,
      'packageId': packageId, // Thêm packageId
      'quantily': quantily, // Thêm quantily
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'] as String,
      email: doc['email'] as String,
      fullname: doc['fullname'] as String,
      picture: doc['picture'] as String?,
      phonenumber: doc['phonenumber'] as String,
      birthday: (doc['birthday'] as Timestamp).toDate(), // Chuyển Timestamp thành DateTime
      role: doc['role'] as String,
      status: doc['status'] as String,
      limit: doc['limit'],
      packageId: doc['packageId'] ?? 'I9DKf6eLpXDqtLnu5t0l', // Đảm bảo giá trị mặc định nếu không tồn tại
      quantily: doc['quantily'] ?? 0, // Đảm bảo giá trị mặc định nếu không tồn tại
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        fullname,
        picture,
        phonenumber,
        birthday,
        role,
        status,
        limit,
        packageId, // Thêm packageId vào props
        quantily, // Thêm quantily vào props
      ];

  @override
  String toString() {
    return '''MyUserEntity: {
      userId: $userId,
      email: $email,
      fullname: $fullname,
      picture: $picture,
      phonenumber: $phonenumber,
      birthday: $birthday,
      role: $role,
      status: $status,
      limit: $limit,
      packageId: $packageId, // In ra packageId
      quantily: $quantily // In ra quantily
    }''';
  }
}