import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String plateNo;
  final String userId;
  final String? brand;
  final String? model;
  final String? color;

  Vehicle({required this.plateNo, required this.userId, this.brand, this.model, this.color});

  // Create a Vehicle instance from a Firestore DocumentSnapshot
  factory Vehicle.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Vehicle(
      plateNo: data?['plateNo'] ?? '',
      userId: data?['userId'] ?? '',
      brand: data?['brand'] ?? '',
      model: data?['model'] ?? '',
      color: data?['color'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'plateNo': plateNo,
            'userId': userId,
            'brand': brand,
            'model': model,
            'color': color
    };
  }

}