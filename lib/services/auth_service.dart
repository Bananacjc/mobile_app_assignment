import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/global_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 🔹 Email login
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // 🔹 Email registration
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user profile to Firestore
      await _db.collection("users").doc(result.user!.uid).set({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // 🔹 Google login
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // cancelled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Save profile to Firestore if new
      if (result.additionalUserInfo!.isNewUser) {
        await _db.collection("users").doc(result.user!.uid).set({
          "firstName": result.user!.displayName?.split(" ").first ?? "",
          "lastName": result.user!.displayName?.split(" ").last ?? "",
          "email": result.user!.email,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // 🔹 Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();

        // Clear global user
    GlobalUser.logout();

    // Clear saved credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }
}