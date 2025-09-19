import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String userId;
  final String? type;
  final DateTime? reminderDate;

  Reminder({required this.userId, this.type, this.reminderDate});

  // Create a Reminder instance from a Firestore DocumentSnapshot
  factory Reminder.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Reminder(
      userId: data?['userId'] ?? '',
      type: data?['type'] ?? '',
      reminderDate: data?['reminderDate'] != null
                    ? (data?['reminderDate'] as Timestamp).toDate()
                    : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': userId,
            'type': type,
            'reminderDate': reminderDate
    };
  }
}