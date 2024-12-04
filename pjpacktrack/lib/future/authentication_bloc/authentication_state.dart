part of 'authentication_bloc.dart';

// Các trạng thái khác nhau của việc xác thực
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu khi chưa rõ người dùng đã xác thực hay chưa
class AuthenticationStateUnknown extends AuthenticationState {
  const AuthenticationStateUnknown();
}

// Trạng thái khi người dùng đã đăng nhập
class AuthenticationStateAuthenticated extends AuthenticationState {
  final User user;

  const AuthenticationStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// Trạng thái khi người dùng chưa đăng nhập
class AuthenticationStateUnauthenticated extends AuthenticationState {
  const AuthenticationStateUnauthenticated();
}

// Trạng thái đang xử lý đăng nhập hoặc đăng xuất
class SignInProcess extends AuthenticationState {}

// Trạng thái đăng nhập thành công
class SignInSuccess extends AuthenticationState {}

// Trạng thái đăng nhập thất bại
class SignInFailure extends AuthenticationState {
  final String error;

  const SignInFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// Trạng thái đang xử lý đăng ký
class SignUpProcess extends AuthenticationState {}

// Trạng thái đăng ký thành công
class SignUpSuccess extends AuthenticationState {}

// Trạng thái đăng ký thất bại
class SignUpFailure extends AuthenticationState {
  final String error;

  const SignUpFailure(this.error);

  @override
  List<Object?> get props => [error];
}