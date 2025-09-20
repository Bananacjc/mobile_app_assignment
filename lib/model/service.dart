import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceId;           // Firestore doc id
  final String userId;              // owner uid
  final String? title;
  final String? note;
  final String? status;
  final double? fee;                // nullable
  final int? duration;              // minutes, nullable
  final DateTime? appointmentDate;  // nullable

  Service({
    required this.serviceId,
    required this.userId,
    this.title,
    this.note,
    this.status,
    this.fee,
    this.duration,
    this.appointmentDate,
  });

  // Firestore -> Service
  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};

    return Service(
      serviceId: (data['serviceId'] as String?) ?? snapshot.id,
      userId: (data['userId'] as String?) ?? '',
      title: data['title'] as String?,
      note: data['note'] as String?,
      status: data['status'] as String?,
      fee: (data['fee'] as num?)?.toDouble(),
      duration: (data['duration'] as num?)?.toInt(),
      appointmentDate: (data['appointmentDate'] as Timestamp?)?.toDate(),
    );
  }

  // Service -> Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'serviceId': serviceId,
      'userId': userId,
    };
    if (title != null) map['title'] = title;
    if (note != null) map['note'] = note;
    if (status != null) map['status'] = status;
    if (fee != null) map['fee'] = fee;
    if (duration != null) map['duration'] = duration;
    if (appointmentDate != null) map['appointmentDate'] = appointmentDate; // DateTime ok
    return map;
  }

  Service copyWith({
    String? serviceId,
    String? userId,
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
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      duration: duration ?? this.duration,
      appointmentDate: appointmentDate ?? this.appointmentDate,
    );
  }
}
