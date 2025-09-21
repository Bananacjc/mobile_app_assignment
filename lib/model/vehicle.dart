// lib/model/vehicle.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String vehicleId;
  final String plateNo;
  final String userId;
  final String? brand;
  final String? model;
  final String? color;

  Vehicle({
    required this.vehicleId,
    required this.plateNo,
    required this.userId,
    this.brand,
    this.model,
    this.color,
  });

  Vehicle copyWith({
    String? vehicleId,
    String? plateNo,
    String? userId,
    String? brand,
    String? model,
    String? color,
  }) {
    return Vehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      plateNo: plateNo ?? this.plateNo,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
    );
  }

  factory Vehicle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? _,
  ) {
    final data = snapshot.data();
    return Vehicle(
      vehicleId: (data?['vehicleId'] as String?) ?? snapshot.id,
      plateNo: (data?['plateNo'] as String?) ?? '',
      userId: (data?['userId'] as String?) ?? '',
      brand: (data?['brand'] as String?) ?? '',
      model: (data?['model'] as String?) ?? '',
      color: (data?['color'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'vehicleId': vehicleId,
      'plateNo': plateNo,
      'userId': userId,
      'brand': brand,
      'model': model,
      'color': color,
    };

    map.removeWhere((_, v) => v == null);
    return map;
  }
}
