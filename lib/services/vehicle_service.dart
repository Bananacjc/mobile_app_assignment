import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/vehicle.dart';

class VehicleService {
  final CollectionReference<Vehicle> _vehiclesCollection = FirebaseFirestore.instance
      .collection('vehicles')
      .withConverter(fromFirestore: Vehicle.fromFirestore, toFirestore: (Vehicle vehicle, _) => vehicle.toFirestore());

  Stream<List<Vehicle>> streamUserVehicles(String userId) {
    return _vehiclesCollection.where('userId', isEqualTo: userId).snapshots().map((s) {
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
      await _vehiclesCollection.doc(plate).set(
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
      print('addOrUpdateVehicle failed: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      print("Error adding vehicle: $e");
      rethrow;
    }
  }

  Future<List<String>> getAllPlateNo(String id) async{
    try {
      final querySnapshot = await _vehiclesCollection.where('userId', isEqualTo: id).get();
      return querySnapshot.docs.map((doc) => doc.id ?? '').toList();
    } catch(e) {
      print("Error fetching all plate no. :$e");
      return [];
    }
  }

  Future<List<Vehicle>> getAllVehicle(String id) async{
    try {
      final querySnapshot = await _vehiclesCollection.where('userId', isEqualTo: id).get();
      final vehicles = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print(data);
        return Vehicle(
            plateNo: doc.id,
            userId: data.userId,
            brand: data.brand,
            model: data.model,
            color: data.color
        );
      }).toList();
      return vehicles;
    } catch(e) {
      print("Error fetching all plate no. :$e");
      return [];
    }
  }

  Future<Vehicle?> getVehicle(String plateNo) async {
    try{
      final querySnapshot = await _vehiclesCollection.doc(plateNo).get();
      if(querySnapshot.exists){
        return querySnapshot.data();
      }
      return null;
    } catch(e) {
      print("Error fetching vehicle. :$e");
      rethrow;
    }
  }

  Future<bool> deleteVehicle(String plateNo) async {
    try {
      await _vehiclesCollection.doc(plateNo.toUpperCase()).delete();
      return true;
    } catch (e) {
      print('deleteVehicle failed: $e');
      rethrow;
    }
  }

  Future<bool> renamePlate({
    required String oldPlateNo,
    required Vehicle newVehicle,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final oldRef = _vehiclesCollection.doc(oldPlateNo.toUpperCase());
      final newRef = _vehiclesCollection.doc(newVehicle.plateNo.toUpperCase());

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
    } catch(e) {
      print("Error deleting vehicle $e");
      return false;
    }
  }
}