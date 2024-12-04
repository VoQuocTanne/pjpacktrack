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

  const MyUserEntity({
    required this.userId,
    required this.email,
    required this.fullname,
    this.picture,
    required this.phonenumber,
    required this.birthday,
    required this.role,
    required this.status,
  });

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'fullname': fullname,
      'picture': picture,
      'phonenumber': phonenumber,
      'birthday':
          Timestamp.fromDate(birthday), // Chuyển DateTime thành Timestamp
      'role': role,
      'status': status,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
        userId: doc['userId'] as String,
        email: doc['email'] as String,
        fullname: doc['fullname'] as String,
        picture: doc['picture'] as String?,
        phonenumber: doc['phonenumber'] as String,
        birthday: (doc['birthday'] as Timestamp)
            .toDate(), // Chuyển Timestamp thành DateTime
        role: doc['role'] as String,
        status: doc['status'] as String);
  }

  @override
  List<Object?> get props =>
      [userId, email, fullname, picture, phonenumber, birthday, role, status];

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
      status: $status
    }''';
  }
}
