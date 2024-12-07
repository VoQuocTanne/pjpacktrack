import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';
import 'package:pjpacktrack/model/user_repo/my_user_entity.dart';
import 'user_repo.dart';

class FirebaseUserRepository implements UserRepository {
  final nameFocusNode = FocusNode();
  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,

    // FacebookLogin? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();
        // _facebookAuth = facebookAuth ?? FacebookLogin();
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  // final FacebookLogin _facebookAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  /// Stream of [MyUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [MyUser.empty] if the user is not authenticated.
  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser;
      return user;
    });
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);

      myUser = myUser.copyWith(userId: user.user!.uid);

      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signInGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final myUser = MyUser(
            userId: userCredential
                .user!.uid, // Hoặc để trống nếu không cần tại thời điểm này
            email: userCredential.user?.email ?? '',
            fullname: userCredential.user!.displayName ?? 'User',
            picture: userCredential.user!.photoURL ?? null, // Nếu không có ảnh
            phonenumber: userCredential.user?.phoneNumber ??
                '', // Nếu chưa có số điện thoại
            birthday: DateTime.now(), // Nếu không có ngày sinh cụ thể
            role: 'user', // Gán quyền mặc định
            status: 'active');

        return myUser;
      } else {
        throw Exception("Sign-In was canceled by user");
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


  @override
  // Future<MyUser> signInFacebook() async {
  //   try {
  //     final FacebookLoginResult loginResult = await _facebookAuth.logIn();
  //     if (loginResult.status == FacebookLoginStatus.success) {
  //       final FacebookAccessToken accessToken = loginResult.accessToken!;
  //       final credential = FacebookAuthProvider.credential(accessToken.token);
  //       final UserCredential userCredential =
  //           await _firebaseAuth.signInWithCredential(credential);
  //       final myUser = MyUser(
  //           userId: userCredential
  //               .user!.uid, // Hoặc để trống nếu không cần tại thời điểm này
  //           email: userCredential.user?.email ?? '',
  //           fullname: userCredential.user!.displayName ?? 'User',
  //           picture: userCredential.user!.photoURL ?? null, // Nếu không có ảnh
  //           phonenumber: userCredential.user?.phoneNumber ??
  //               '', // Nếu chưa có số điện thoại
  //           birthday: DateTime.now(), // Nếu không có ngày sinh cụ thể
  //           role: 'user', // Gán quyền mặc định
  //           status: 'active');

  //       return myUser;
  //     } else {
  //       throw Exception("Sign-In was canceled by user");
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }

  @override
  Future<void> logOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      // await _facebookAuth.logOut();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser user) async {
    try {
      await usersCollection.doc(user.userId).set(user.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> getMyUser(String myUserId) async {
    try {
      return usersCollection.doc(myUserId).get().then((value) =>
          MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadPicture(String file, String userId) async {
    try {
      File imageFile = File(file);
      Reference firebaseStoreRef =
          FirebaseStorage.instance.ref().child('$userId/PP/${userId}_lead');
      await firebaseStoreRef.putFile(
        imageFile,
      );
      String url = await firebaseStoreRef.getDownloadURL();
      await usersCollection.doc(userId).update({'picture': url});
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {
      log('Error getting user ID: $e');
      rethrow;
    }
  }
}
