import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String userId;
  final String plateNo;
  final String? type;
  final DateTime? reminderDate;

  Reminder({
    required this.userId,
    required this.plateNo,
    this.type,
    this.reminderDate,
  });

  factory Reminder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Reminder(
      userId: data?['userId'] ?? '',
      plateNo: data?['plateNo'] ?? '',
      type: data?['type'] ?? '',
      reminderDate: (data?['reminderDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'plateNo': plateNo,   // NEW
        'type': type,
        'reminderDate': reminderDate,
      };
}
