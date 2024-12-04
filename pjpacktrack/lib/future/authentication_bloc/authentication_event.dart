part of 'authentication_bloc.dart';

// Các sự kiện liên quan đến đăng nhập, đăng ký, đăng xuất và thay đổi trạng thái
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

// Khi trạng thái người dùng thay đổi (lắng nghe từ Firebase)
class AuthenticationUserChanged extends AuthenticationEvent {
  final User? user;

  const AuthenticationUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

// Sự kiện đăng nhập với Google
class SignInWithGoogleRequested extends AuthenticationEvent {}

// Sự kiện đăng nhập với Facebook
class SignInWithFacebookRequested extends AuthenticationEvent {}

// Sự kiện đăng nhập với email và password
class SignInRequired extends AuthenticationEvent {
  final String email;
  final String password;

  const SignInRequired(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// Sự kiện đăng ký người dùng mới
class SignUpRequired extends AuthenticationEvent {
  final MyUser user;
  final String password;

  const SignUpRequired(this.user, this.password);

  @override
  List<Object?> get props => [user, password];
}

// Sự kiện đăng xuất
class SignOutRequired extends AuthenticationEvent {
  const SignOutRequired();
}