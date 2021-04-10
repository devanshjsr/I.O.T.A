import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/shared_preferences.dart';
import '../screens/auth/welcome_screen.dart';

//  Provider which gives all the functionalities to create id, login, signout, change id details
class AuthProvider {
  final FirebaseAuth _firebaseAuth;
  AuthProvider(this._firebaseAuth);

  //  If we get a user, we go to homepage, else to welcome page
  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  //  Method to login with email and password
  Future<String> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      var userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      //  Refetch and store fcm token in case it refreshes
      String token = await FirebaseMessaging().getToken();
      // print(userCredentials.user.uid);
      var studentCheck = await FirebaseFirestore.instance
          .collection("Student")
          .doc(userCredentials.user.uid)
          .collection("MyData")
          .get();
      if (studentCheck.docs.isNotEmpty) {
        await MySharedPreferences.isStudentSave(true);
        FirebaseFirestore.instance
            .collection("Student")
            .doc(userCredentials.user.uid)
            .collection("MyData")
            .doc(studentCheck.docs.first.id)
            .update(
          {"fcmToken": token},
        );
        return "Student";
      } else {
        await MySharedPreferences.isStudentSave(false);

        var data = await FirebaseFirestore.instance
            .collection("Faculty")
            .doc(userCredentials.user.uid)
            .collection("MyData")
            .get();

        FirebaseFirestore.instance
            .collection("Faculty")
            .doc(userCredentials.user.uid)
            .collection("MyData")
            .doc(data.docs.first.id)
            .update(
          {"fcmToken": token},
        );
        return "Faculty";
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      final ScaffoldMessengerState scaffoldMessenger =
          ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: TextStyle(fontSize: 9),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return e.message;
    }
  }

  //  Method to sign-out user and go to welcome screen
  Future<void> signOutUser(BuildContext context) async {
    await _firebaseAuth.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        WelcomeScreen.routeName, (Route<dynamic> route) => false);
    print("signed out");
    // notifyListeners();
  }

  //  Method to sign-up with email and password
  //  Store other details of the user in firestore
  //  Also store current user type(Student/Faculty) in sharedpreferences
  Future<String> signUpWithEmailAndPassword(Map<String, String> _authData,
      BuildContext context, bool isStudent) async {
    try {
      var signupType = isStudent ? "Student" : "Faculty";
      UserCredential userId =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: _authData["email"], password: _authData["password"]);
      User user = userId.user;
      user.updateProfile(displayName: _authData["name"]);
      try {
        userId.user.sendEmailVerification();
        Fluttertoast.showToast(
            msg: "A verification link has been sent to your e-mail");
        String token = await FirebaseMessaging().getToken();

        final CollectionReference collectionReference = FirebaseFirestore
            .instance
            .collection(signupType)
            .doc(userId.user.uid)
            .collection("MyData");
        await collectionReference.add(
          {
            "name": _authData["name"],
            "mobileNumber": _authData["mobileNumber"],
            "email": _authData["email"],
            "fcmToken": token
          },
        );
      }
      //  throw the error to the screen/widget using the method
      catch (error) {
        throw error;
      }
      MySharedPreferences.isStudentSave(isStudent);
      // notifyListeners();
      return "Signed Up";
    } on FirebaseAuthException catch (e) {
      print(e);
      final ScaffoldMessengerState scaffoldMessenger =
          ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: TextStyle(fontSize: 9),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return e.message;
    }
  }

  Future<void> verifyEmail() async {
    await _firebaseAuth.currentUser.sendEmailVerification();
    Fluttertoast.showToast(
        msg: "A verification link has been sent to your e-mail");
  }

  //  Method to send a password verification link
  Future<void> resetPassword(String email) async {
    _firebaseAuth.sendPasswordResetEmail(email: email).catchError((onError) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: onError.message, backgroundColor: Colors.red);
    });
  }
}
