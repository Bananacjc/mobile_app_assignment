import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String plateNo;
  final String userId;
  final String? brand;
  final String? model;
  final String? color;      // hex string like #FFFFFF

  Vehicle({
    required this.plateNo,
    required this.userId,
    this.brand,
    this.model,
    this.color,
  });

  factory Vehicle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Vehicle(
      plateNo: (data?['plateNo'] as String?) ?? snapshot.id,
      userId: (data?['userId'] as String?) ?? '',
      brand: data?['brand'] as String?,
      model: data?['model'] as String?,
      color: data?['color'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'plateNo': plateNo,
      'userId': userId,
      'brand': brand,
      'model': model,
      'color': color,
    };
  }
}
