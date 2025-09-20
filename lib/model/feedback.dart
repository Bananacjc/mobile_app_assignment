import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final String serviceId;
  final int? star;
  final String? comment;

  Feedback({required this.serviceId, this.star, this.comment});

  factory Feedback.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Feedback(
      serviceId: data?['serviceId'] ?? '',
      star: data?['star'] ?? 0,
      comment: data?['comment'] ?? ''
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'serviceId': serviceId,
    };
    if(star != null && star != 0){
      data['star'] = star;
    }

    if(comment != null){
      data['comment'] = comment;
    }

    return data;
  }
}