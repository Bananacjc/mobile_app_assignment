// model/service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceId;           // Firestore doc id
  final String userId;              // owner uid
  final String plateNo;             // vehicle plate
  final String? title;
  final String? note;
  final String? status;
  final double? fee;                // nullable
  final int? duration;              // minutes, nullable
  final DateTime? appointmentDate;  // nullable

  Service({
    required this.serviceId,
    required this.userId,
    required this.plateNo,
    this.title,
    this.note,
    this.status,
    this.fee,
    this.duration,
    this.appointmentDate,
  });

  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Service(
      serviceId: (data['serviceId'] as String?) ?? snapshot.id,
      userId: (data['userId'] as String?) ?? '',
      plateNo: (data['plateNo'] as String?) ?? '',
      title: data['title'] as String?,
      note: data['note'] as String?,
      status: data['status'] as String?,
      fee: (data['fee'] as num?)?.toDouble(),
      duration: (data['duration'] as num?)?.toInt(),
      appointmentDate: (data['appointmentDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    // Include fee & duration even when null so they are stored as null.
    return <String, dynamic>{
      'serviceId': serviceId,
      'userId': userId,
      'plateNo': plateNo,                // <-- fixed
      'title': title,
      'note': note,
      'status': status,
      'fee': fee,                        // may be null -> saved as null
      'duration': duration,              // may be null -> saved as null
      'appointmentDate': appointmentDate,
    };
  }

  Service copyWith({
    String? serviceId,
    String? userId,
    String? plateNo,
    String? title,
    String? note,
    String? status,
    double? fee,
    int? duration,
    DateTime? appointmentDate,
  }) {
    return Service(
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      plateNo: plateNo ?? this.plateNo,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      duration: duration ?? this.duration,
      appointmentDate: appointmentDate ?? this.appointmentDate,
    );
  }
}
