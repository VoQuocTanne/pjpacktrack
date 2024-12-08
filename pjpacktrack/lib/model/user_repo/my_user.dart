import 'package:equatable/equatable.dart';
import 'package:pjpacktrack/model/user_repo/my_user_entity.dart';

class MyUser extends Equatable {
  final String userId;
  late final String email;
  late String fullname;
  String? picture;
  late String phonenumber;
  late DateTime birthday; // Chuyển đổi sang DateTime
  final String role;
  final String status;
  final String rank;
  final int limit;
  final int quantity;

  MyUser({
    required this.userId,
    required this.email,
    required this.fullname,
    this.picture,
    required this.phonenumber,
    required this.birthday, // Chuyển đổi sang DateTime
    required this.role,
    required this.status,
    required this.rank,
    required this.limit,
    required this.quantity,
  });

  /// Empty user which represents an unauthenticated user.
  static final empty = MyUser(
    userId: '',
    email: '',
    fullname: '',
    picture: null,
    phonenumber: '',
    birthday: DateTime.now(),
    role: 'user',
    status: 'active',
    rank: 'free',
    limit: 50,
    quantity: 0,
  );

  /// Modify MyUser parameters
  MyUser copyWith({
    String? userId,
    String? email,
    String? fullname,
    String? picture,
    String? phonenumber,
    DateTime? birthday, // Chuyển đổi sang DateTime
    String? role,
    String? status,
    String? rank,
    int? limit,
    int? quantity,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      picture: picture ?? this.picture,
      phonenumber: phonenumber ?? this.phonenumber,
      birthday: birthday ?? this.birthday,
      // Chuyển đổi sang DateTime
      role: role ?? this.role,
      status: status ?? this.status,
      rank: rank ?? this.rank,
      limit: limit ?? this.limit,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == MyUser.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != MyUser.empty;

  /// Chuyển MyUser thành MyUserEntity để lưu trữ
  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      fullname: fullname,
      picture: picture,
      phonenumber: phonenumber,
      birthday: birthday,
      // Sử dụng DateTime
      role: role,
      status: status,
      rank: rank,
      quantity: quantity,
      limit: limit,
    );
  }

  /// Tạo MyUser từ MyUserEntity khi đọc từ Firestore
  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      fullname: entity.fullname,
      picture: entity.picture,
      phonenumber: entity.phonenumber,
      birthday: entity.birthday,
      // Sử dụng DateTime từ entity
      role: entity.role,
      status: entity.status,
      rank: entity.rank,
      quantity: entity.quantity,
      limit: entity.limit,
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
        rank,
        quantity,
        limit
      ];
}
