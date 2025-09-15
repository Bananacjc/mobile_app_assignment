import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String email;
  final String? displayName;

  User({this.id, required this.email, this.displayName});

  // Create a User instance from a Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return User(id: snapshot.id, email: data?['email'] ?? '', displayName: data?['displayName'] ?? '');
  }

  // Convert the User instance to a Map for Firestore
  // Something like toJSON()
  Map<String, dynamic> toFirestore() {
    return {'email': email, if (displayName != null) 'displayName': displayName};
  }

  User copyWith({String? id, String? email, String? displayName}) {
    return User(id: id ?? this.id, email: email ?? this.email, displayName: displayName ?? this.displayName);
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName)';
  }
}
