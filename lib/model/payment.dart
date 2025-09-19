import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String userId;
  final String? type;
  final Map<String, String>? detail;

  Payment({required this.userId, this.type, this.detail});

  // Create a Payment instance from a Firestore DocumentSnapshot
  factory Payment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Payment(
      userId: data?['userId'] ?? '',
      type: data?['type'] ?? '',
      detail: data?['detail'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'userId': userId,
      'type': type,
    };

    if(detail != {}){
      data['detail'] = detail;
    };

    return data;
  }
}