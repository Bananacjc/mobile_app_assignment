// global_user.dart
import 'package:firebase_auth/firebase_auth.dart';

class GlobalUser {
  static User? user; // Firebase User
  static void logout() {
    user = null;
  }
}