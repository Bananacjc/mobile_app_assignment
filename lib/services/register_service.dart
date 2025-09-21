// lib/services/register_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class RegisterService {
  final AuthService _authService = AuthService();

  Future<User?> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      // ✅ Create user with Firebase Auth
      final user = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (user != null) {
        // ✅ Update Firebase profile with full name
        final fullName = "$firstName $lastName";
        await user.updateDisplayName(fullName);
        await user.reload();

        return FirebaseAuth.instance.currentUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      rethrow;
    }
  }
}