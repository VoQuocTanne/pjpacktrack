import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';
import 'package:pjpacktrack/model/user_repo/user_repo.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(const AuthenticationStateUnknown()) {
    // Lắng nghe thay đổi trạng thái người dùng từ Firebase
    _userSubscription = userRepository.user.listen((authUser) {
      add(AuthenticationUserChanged(authUser));
    });

    // Xử lý khi trạng thái người dùng thay đổi
    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != null) {
        emit(AuthenticationStateAuthenticated(event.user!));
      } else {
        emit(const AuthenticationStateUnauthenticated());
      }
    });

    // Xử lý sự kiện đăng nhập với Google
    on<SignInWithGoogleRequested>((event, emit) async {
      emit(SignInProcess());
      try {
        MyUser user = await userRepository.signInGoogle();
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.userId);
        final userSnapshot = await userDoc.get();
        if (!userSnapshot.exists) {
          await userRepository.setUserData(user);
        }
        emit(SignInSuccess());
      } catch (e) {
        emit(SignInFailure(e.toString()));
      }
    });

    // Xử lý sự kiện đăng nhập với Facebook
    on<SignInWithFacebookRequested>((event, emit) async {
      emit(SignInProcess());
      try {
        MyUser user = await userRepository.signInFacebook();
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.userId);
        final userSnapshot = await userDoc.get();
        if (!userSnapshot.exists) {
          await userRepository.setUserData(user);
        }
        emit(SignInSuccess());
      } catch (e) {
        emit(SignInFailure(e.toString()));
      }
    });

    // Xử lý sự kiện đăng nhập với email và password
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        await userRepository.signIn(event.email, event.password);
        emit(SignInSuccess());
      } catch (e) {
        emit(SignInFailure(e.toString()));
      }
    });

    // Xử lý sự kiện đăng ký người dùng mới
    on<SignUpRequired>((event, emit) async {
      emit(SignUpProcess());
      try {
        MyUser user = await userRepository.signUp(event.user, event.password);
        await userRepository.setUserData(user);
        emit(SignUpSuccess());
      } catch (e) {
        emit(SignUpFailure(e.toString()));
      }
    });

    // Xử lý sự kiện đăng xuất
    on<SignOutRequired>((event, emit) async {
      try {
        await userRepository.logOut(); // Thực hiện đăng xuất
        emit(
            const AuthenticationStateUnauthenticated()); // Phát trạng thái không đăng nhập
      } catch (e) {
        emit(
            const AuthenticationStateUnauthenticated()); // Dù có lỗi cũng phát trạng thái không đăng nhập
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
