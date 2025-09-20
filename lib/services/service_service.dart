import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/service.dart';

class ServiceService {
  final CollectionReference<Service> _servicesCollection = FirebaseFirestore
      .instance
      .collection('services')
      .withConverter(
        fromFirestore: Service.fromFirestore,
        toFirestore: (Service service, _) => service.toFirestore(),
      );

  Future<DocumentReference<Service>?> addService(Service service) async {
    try {
      final doc = _servicesCollection.doc(); // create doc to get id
      final toSave = service.copyWith(serviceId: doc.id);
      await doc.set(toSave);
      return doc;
    } catch (e) {
      print("Error adding service: $e");
      return null;
    }
  }

  Future<bool> updateService(Service service) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('serviceId', isEqualTo: service.serviceId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _servicesCollection
            .doc(querySnapshot.docs[0].id)
            .set(service, SetOptions(merge: true));
        return true;
      }
    } catch (e) {
      print("Error updating service: $e");
    }
    return false;
  }

  Future<bool> updateServiceStatus(String serviceId, String status) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('serviceId', isEqualTo: serviceId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        await _servicesCollection.doc(querySnapshot.docs[0].id).update({
          'status': status,
        });
        return true;
      }
    } catch (e) {
      print("Error updating service status: $e");
    }
    return false;
  }

  Future<List<Service>> getAllServices(String userId) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('userId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print("Error fetching all services: $e");
    }
    return [];
  }

  Future<void> rescheduleService(
    String serviceId,
    DateTime newAppointmentDate,
  ) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('serviceId', isEqualTo: serviceId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        await _servicesCollection.doc(querySnapshot.docs[0].id).update({
          'appointmentDate': newAppointmentDate,
        });
      }
    } catch (e) {
      print("Error rescheduling service: $e");
    }
  }
}
