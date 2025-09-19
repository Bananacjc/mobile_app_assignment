import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceId;
  final String userId;
  final String? title;
  final String? type;
  final String? status;
  final double? fee;
  final int? duration; // minutes
  final DateTime? appointmentDate;

  Service({required this.serviceId, required this.userId, this.title, this.type, this.status, this.fee, this.duration, this.appointmentDate});

  // Create a Payment instance from a Firestore DocumentSnapshot
  factory Service.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Service(
      serviceId: data?['serviceId'] ?? '',
      userId: data?['userId'] ?? '',
      title: data?['title'] ?? '',
      type: data?['type'] ?? '',
      status: data?['status'] ?? '',
      fee: double.tryParse(data?['fee']) ?? 0,
      duration: int.tryParse(data?['duration']) ?? 0,
      appointmentDate: data?['appointmentDate'] != null
          ? (data?['appointmentDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'serviceId': serviceId,
      'userId': userId,
      'title': title,
      'type': type,
      'status': status,
      'fee': fee,
      'duration': duration,
    };
      if(appointmentDate != null){
        data['appointmentDate'] = appointmentDate;
      }

    return data;
  }
}