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

  Future<List<Service>> getAllActiveServices(String userId) async {
    try {
      DateTime now = DateTime.now();

      final querySnapshot = await _servicesCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final allServices = querySnapshot.docs
            .map((doc) => doc.data())
            .toList();

        final activeServices =
        allServices.where((s) => s.status != "completed").toList();

        final inProgressServices = activeServices.where((s) {
          return s.appointmentDate != null && s.appointmentDate!.isAfter(now);
        }).toList();

        print("In-Progress Services count: ${inProgressServices.length}");
        return inProgressServices;
      }
    } catch (e) {
      print("Error fetching active services: $e");
    }
    return [];
  }

  Future<List<Service>> getAllCompletedServices(String userId) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final allServices = querySnapshot.docs
            .map((doc) => doc.data())
            .toList();

        final completedServices =
        allServices.where((s) => s.status == "completed").toList();

        print("Completed Services count: ${completedServices.length}");
        return completedServices;
      }
    } catch (e) {
      print("Error fetching completed services: $e");
    }
    return [];
  }

  Future<List<Service>> getInProgressServices(String userId) async {
    try {
      DateTime now = DateTime.now();

      final querySnapshot = await _servicesCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final allServices = querySnapshot.docs
            .map((doc) => doc.data())
            .toList();

        final activeServices =
        allServices.where((s) => s.status != "completed").toList();

        final inProgressServices = activeServices.where((s) {
          return s.appointmentDate != null && s.appointmentDate!.isBefore(now);
        }).toList();

        print("In-Progress Services count: ${inProgressServices.length}");
        return inProgressServices;
      }
    } catch (e) {
      print("Error fetching in-progress services: $e");
    }
    return [];
  }

  Future<Service?> getSelectedCompletedServices(String userId, String title) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final allServices = querySnapshot.docs
            .map((doc) => doc.data())
            .toList();

        final filtered = allServices
            .where((s) => s.status == "completed" && s.title == title).toList();

        if(filtered.isNotEmpty){
          filtered.sort((a, b) {
            final dateA = a.appointmentDate ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = b.appointmentDate ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA); // descending order (latest -> oldest)
          });

          return filtered.first;
        }
      }
    } catch (e) {
      print("Error fetching selected completed services: $e");
    }
    return null;
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
