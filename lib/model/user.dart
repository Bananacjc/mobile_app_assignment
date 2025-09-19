import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
class User {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String password;

  User({this.id, this.firstName, this.lastName, required this.email, required this.password});

  // Create a User instance from a Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return User(
        id: snapshot.id,
        firstName: data?['firstName'] ?? '',
        lastName: data?['lastName'] ?? '',
        email: data?['email'] ?? '',
        password: data?['password'] ?? '');
  }

  // Convert the User instance to a Map for Firestore
  // Something like toJSON()
  Map<String, dynamic> toFirestore() {
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    return {if (firstName != null) 'firstName': firstName,
            if (lastName != null) 'lastName': lastName,
            'email': email,
            'password': hashedPassword};
  }

  User copyWith({String? id, String? firstName, String? lastName, String? email, String? password}) {
    return User(id: id ?? this.id,
                firstName: firstName ?? this.firstName,
                lastName: lastName ?? this.lastName,
                email: email ?? this.email,
                password: password ?? this.password);
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email})';
  }
}
