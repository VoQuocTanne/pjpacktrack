import 'package:firebase_auth/firebase_auth.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';

abstract class UserRepository {
  Stream<User?> get user;

  Future<void> signIn(String email, String password);

  Future<MyUser> signInGoogle();

  //Future<MyUser> signInFacebook();

  Future<void> logOut();

  //Future<MyUser> signUp(MyUser myUser, String password);
  Future<MyUser> signUp(MyUser user, String password) async {
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: user.email, password: password);

    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception("Unable to sign up user.");
    }

    return MyUser(
      userId: firebaseUser.uid,
      email: user.email,
      fullname: user.fullname,
      phonenumber: user.phonenumber,
      picture: user.picture,
      birthday: user.birthday,
      role: user.role,
      status: user.status,
      quantily: user.quantily,
      limit: user.limit,
      packageId: user.packageId,
    );
  }

  Future<void> resetPassword(String email);

  Future<void> setUserData(MyUser user);

  Future<MyUser> getMyUser(String myUserId);

  Future<String> uploadPicture(String file, String userId);

  Future<String?> getUserId();
}
