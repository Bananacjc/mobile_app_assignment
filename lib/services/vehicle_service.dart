import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/vehicle.dart';

class VehicleService {
  final CollectionReference<Vehicle> _col = FirebaseFirestore.instance
      .collection('vehicles')
      .withConverter<Vehicle>(
        fromFirestore: Vehicle.fromFirestore,
        toFirestore: (v, _) => v.toFirestore(),
      );

  Stream<List<Vehicle>> streamUserVehicles(String userId) {
    return _col.where('userId', isEqualTo: userId).snapshots().map((s) {
      final list = s.docs.map((d) => d.data()).toList();
      list.sort((a, b) => a.plateNo.compareTo(b.plateNo));
      return list;
    });
  }

  /// Upsert by plateNo (document id). Returns true on success.
  Future<bool> addOrUpdateVehicle(Vehicle v) async {
    try {
      final plate = v.plateNo.trim().toUpperCase();
      if (plate.isEmpty) {
        throw 'Plate number is empty';
      }
      await _col.doc(plate).set(
            Vehicle(
              plateNo: plate,
              userId: v.userId,
              brand: v.brand,
              model: v.model,
              color: v.color,
            ),
            SetOptions(merge: true),
          );
      return true;
    } on FirebaseException catch (e) {
      debugPrint('addOrUpdateVehicle failed: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('addOrUpdateVehicle failed: $e');
      rethrow;
    }
  }

  Future<bool> deleteVehicle(String plateNo) async {
    try {
      await _col.doc(plateNo.toUpperCase()).delete();
      return true;
    } catch (e) {
      debugPrint('deleteVehicle failed: $e');
      rethrow;
    }
  }

  Future<bool> renamePlate({
    required String oldPlateNo,
    required Vehicle newVehicle,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final oldRef = _col.doc(oldPlateNo.toUpperCase());
      final newRef = _col.doc(newVehicle.plateNo.toUpperCase());

      batch.set(
        newRef,
        Vehicle(
          plateNo: newVehicle.plateNo.toUpperCase(),
          userId: newVehicle.userId,
          brand: newVehicle.brand,
          model: newVehicle.model,
          color: newVehicle.color,
        ),
      );
      batch.delete(oldRef);
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('renamePlate failed: $e');
      rethrow;
    }
  }
}
