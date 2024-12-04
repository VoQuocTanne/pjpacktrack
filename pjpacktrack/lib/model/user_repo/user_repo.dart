import 'package:firebase_auth/firebase_auth.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';

abstract class UserRepository {
  Stream<User?> get user;

  Future<void> signIn(String email, String password);

  Future<MyUser> signInGoogle();

  // Future<MyUser> signInFacebook();

  Future<void> logOut();

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> resetPassword(String email);

  Future<void> setUserData(MyUser user);

  Future<MyUser> getMyUser(String myUserId);

  Future<String> uploadPicture(String file, String userId);

  Future<String?> getUserId();
}
