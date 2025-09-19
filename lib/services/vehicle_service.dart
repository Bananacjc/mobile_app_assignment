import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/vehicle.dart';

class VehicleService {
  final CollectionReference<Vehicle> _vehiclesCollection = FirebaseFirestore.instance
      .collection('vehicles')
      .withConverter(fromFirestore: Vehicle.fromFirestore, toFirestore: (Vehicle vehicle, _) => vehicle.toFirestore());

  Future<DocumentReference<Vehicle>?> addVehicle(Vehicle vehicle) async{
    try{
      print("Vehicle successfully added.");
      final doc = _vehiclesCollection.doc(vehicle.plateNo); // set plateNo as doc id
      await doc.set(vehicle);
      return doc;
    } catch (e) {
      print("Error adding vehicle: $e");
      return null;
    }
  }

  Future<List<String>> getAllPlateNo(String id) async{
    try {
      final querySnapshot = await _vehiclesCollection.get();
      return querySnapshot.docs.map((doc) => doc.id ?? '').toList();
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

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try{
      final querySnapshot = await _vehiclesCollection.where('plateNo', isEqualTo: vehicle.plateNo).get();
      if (querySnapshot.docs.isNotEmpty){
        await _vehiclesCollection.doc(vehicle.plateNo).set(vehicle,SetOptions(merge: true));
        return true;
      }
      return false;
    } catch(e) {
      print("Error updating vehicle $e");
      rethrow;
    }
  }

  Future<bool> deleteVehicle(String plateNo) async {
    try{
      await _vehiclesCollection.doc(plateNo).delete();
      return true;
    } catch(e) {
      print("Error deleting vehicle $e");
      return false;
    }
  }
}