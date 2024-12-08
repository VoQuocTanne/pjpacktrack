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
  late String packageId; // Thêm packageId
  late int quantily; // Thêm quantily

  MyUser({
    required this.userId,
    required this.email,
    required this.fullname,
    this.picture,
    required this.phonenumber,
    required this.birthday, // Chuyển đổi sang DateTime
    required this.role,
    required this.status,
    required this.packageId, // Thêm packageId
    required this.quantily, // Thêm quantily
  });

  /// Empty user which represents an unauthenticated user.
  static final empty = MyUser(
    userId: '', // Hoặc để trống nếu không cần tại thời điểm này
    email: '',
    fullname: '',
    picture: null, // Nếu không có ảnh
    phonenumber: '', // Nếu chưa có số điện thoại
    birthday: DateTime.now(), // Nếu không có ngày sinh cụ thể
    role: 'user',
    status: 'active',
    packageId: 'I9DKf6eLpXDqtLnu5t0l', // Giá trị mặc định
    quantily: 0, // Giá trị mặc định
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
    String? packageId, // Thêm packageId
    int? quantily, // Thêm quantily
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      picture: picture ?? this.picture,
      phonenumber: phonenumber ?? this.phonenumber,
      birthday: birthday ?? this.birthday, // Chuyển đổi sang DateTime
      role: role ?? this.role,
      status: status ?? this.status,
      packageId: packageId ?? this.packageId, // Thêm packageId
      quantily: quantily ?? this.quantily, // Thêm quantily
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
      birthday: birthday, // Sử dụng DateTime
      role: role,
      status: status,
      packageId: packageId, // Thêm packageId
      quantily: quantily, // Thêm quantily (tên trường trong entity là quantity)
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
      birthday: entity.birthday, // Sử dụng DateTime từ entity
      role: entity.role,
      status: entity.status,
      packageId: entity.packageId, // Thêm packageId
      quantily: entity.quantily, // Thêm quantily (tên trường trong entity là quantity)
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
        packageId, // Thêm packageId vào props
        quantily, // Thêm quantily vào props
      ];
}