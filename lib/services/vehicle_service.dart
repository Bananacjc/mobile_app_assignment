import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/vehicle.dart';

class VehicleService {
  // Typed collection with converters
  final CollectionReference<Vehicle> _vehicles =
      FirebaseFirestore.instance
          .collection('vehicles')
          .withConverter<Vehicle>(
            fromFirestore: Vehicle.fromFirestore,
            toFirestore: (Vehicle v, _) => v.toFirestore(),
          );

  /// Live stream of this user's vehicles (updates in real time)
  Stream<List<Vehicle>> streamUserVehicles(String userId) {
    return _vehicles
        .where('userId', isEqualTo: userId)
        .orderBy('plateNo')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Add a vehicle and assign a generated vehicleId
  Future<void> addVehicle(Vehicle v) async {
    // Pre-create a doc so we can set vehicleId == doc.id
    final docRef = _vehicles.doc();
    final withId = Vehicle(
      vehicleId: docRef.id,
      userId: v.userId,
      plateNo: v.plateNo,
      brand: v.brand,
      model: v.model,
      color: v.color, // hex string like "#1E90FF"
    );
    await docRef.set(withId);
  }

  /// Update (merge) an existing vehicle by its vehicleId
  Future<void> updateVehicle(Vehicle v) async {
    if (v.vehicleId.isEmpty) {
      throw ArgumentError('vehicleId is required for updateVehicle');
    }
    await _vehicles.doc(v.vehicleId).set(v, SetOptions(merge: true));
  }

  /// Delete by vehicleId
  Future<void> deleteVehicle(String vehicleId) async {
    await _vehicles.doc(vehicleId).delete();
  }

  /// (Optional) one-time fetch (not streamed)
  Future<List<Vehicle>> getUserVehiclesOnce(String userId) async {
    final snap = await _vehicles.where('userId', isEqualTo: userId).get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
