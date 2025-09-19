import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';

class UserService {
  final CollectionReference<User> _usersCollection = FirebaseFirestore.instance
      .collection('users')
      .withConverter(fromFirestore: User.fromFirestore, toFirestore: (User user, _) => user.toFirestore());

  Future<User?> getUserById(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      rethrow;
    }
  }

  Future<DocumentReference<User>?> addUser(User user) async {
    try {
      print("User successfully added");
      return await _usersCollection.add(user);
    } catch (e) {
      print("Error adding user: $e");
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    if (user.id == null) {
      print("Error: User ID is null. Cannot Update.");
      throw ArgumentError("User ID cannot be null for an update operation.");
    }
    try {
      await _usersCollection.doc(user.id).set(user, SetOptions(merge: true));
      print("User ${user.id} updated successfully.");
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  Future<void> updateUserDisplayName(String userId, String newName) async {
    try {
      await _usersCollection.doc(userId).update({'displayName': newName});
    } catch (e) {
      print("Error updating user display name: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is empty. Cannot delete.");
      throw ArgumentError("User ID cannot be empty for a delete operation.");
    }
    try {
      await _usersCollection.doc(userId).delete();
      print("User $userId deleted successfully.");
    } catch (e) {
      print("Error deleting user: $e");
      rethrow;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print("Error fetching user by email: $e");
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection.get();
      final users = querySnapshot.docs.map((doc) => doc.data()).toList();
      return users;
    } catch (e) {
      print("Error fetching all users: $e");
      rethrow;
    }
  }

  Future<bool> userLogin(String email, String password) async {
    try{
      final querySnapshot = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
      if(querySnapshot.docs.isNotEmpty) {
        final user = querySnapshot.docs.first.data();
        return BCrypt.checkpw(password, user.password);
      }
      return false;
    }catch(e) {
      print("Error occurred in login: $e");
      rethrow;
    }
  }
}