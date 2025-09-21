import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../model/global_user.dart';
import 'sqlite_service.dart';

class AccountService {
  final SQLiteService _sqliteService = SQLiteService();
  final ImagePicker _picker = ImagePicker();

  // 🔹 Load user from Firebase + SQLite
  Future<Map<String, dynamic>> loadUserData() async {
    final user = GlobalUser.user;
    Map<String, dynamic> result = {
      "firstName": "",
      "lastName": "",
      "email": "",
      "password": "••••••••",
      "profileImage": null,
    };

    if (user != null) {
      await _sqliteService.insertUserIfNotExists(user.uid, user.email ?? "");

      final displayName = user.displayName ?? "";
      final parts = displayName.split(" ");
      result["firstName"] = parts.isNotEmpty ? parts.first : "";
      result["lastName"] = parts.length > 1 ? parts.sublist(1).join(" ") : "";
      result["email"] = user.email ?? "";

      final dbUser = await _sqliteService.getUserById(user.uid);
      if (dbUser != null && dbUser['profile_picture'] != null) {
        result["profileImage"] = File(dbUser['profile_picture']);
      }
    }
    return result;
  }

  // 🔹 Save picked image locally
  Future<String> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final newPath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final newImage = await image.copy(newPath);
    return newImage.path;
  }

  // 🔹 Pick image from gallery and save
  Future<File?> pickAndSaveImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final File file = File(image.path);
    final savedPath = await saveImageLocally(file);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _sqliteService.updateProfilePicture(user.uid, savedPath);
    }

    return File(savedPath);
  }

  // 🔹 Save edited fields
  Future<bool> saveField(String field, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      bool changed = false;

      if (field == 'firstName' || field == 'lastName') {
        final newName = "${data['firstName']} ${data['lastName']}".trim();
        if (newName != (user.displayName ?? "")) {
          await user.updateDisplayName(newName);
          await user.reload();
          GlobalUser.user = FirebaseAuth.instance.currentUser;

          await _sqliteService.insertOrUpdateUser({
            'id': user.uid,
            'firstName': data['firstName'],
            'lastName': data['lastName'],
            'email': user.email,
            'profile_picture': data['profileImage']?.path
          });

          changed = true;
        }
      } else if (field == 'email') {
        final newEmail = data['email'].trim();
        if (newEmail != user.email) {
          await user.verifyBeforeUpdateEmail(newEmail);
          await user.reload();
          GlobalUser.user = FirebaseAuth.instance.currentUser;
          changed = true;
        }
      } else if (field == 'password') {
        final newPassword = data['password'].trim();
        if (newPassword.isNotEmpty) {
          await user.updatePassword(newPassword);
          await user.reload();
          GlobalUser.user = FirebaseAuth.instance.currentUser;
          changed = true;
        }
      }

      return changed;
    } catch (e) {
      rethrow;
    }
  }
}