import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/reminder.dart';

class ReminderService {
  final CollectionReference<Reminder> _remindersCollection =
      FirebaseFirestore.instance
          .collection('reminders')
          .withConverter<Reminder>(
            fromFirestore: Reminder.fromFirestore,
            toFirestore: (r, _) => r.toFirestore(),
          );

  Future<DocumentReference<Reminder>?> addReminder(Reminder reminder) async {
    try {
      return await _remindersCollection.add(reminder);
    } catch (e) {
      print("Error adding reminder: $e");
      return null;
    }
  }

  Future<bool> updateReminder(Reminder reminder) async {
    try {
      final qs = await _remindersCollection
          .where('userId', isEqualTo: reminder.userId)
          .where('plateNo', isEqualTo: reminder.plateNo)
          .where('type', isEqualTo: reminder.type)
          .limit(1)
          .get();

      if (qs.docs.isNotEmpty) {
        await _remindersCollection
            .doc(qs.docs.first.id)
            .set(reminder, SetOptions(merge: true));
        return true;
      }
    } catch (e) {
      print("Error updating reminder: $e");
    }
    return false;
  }

  Future<List<Reminder>> getAllReminder(String userId) async {
    try {
      final qs =
          await _remindersCollection.where('userId', isEqualTo: userId).get();
      return qs.docs.map((d) => d.data()).toList();
    } catch (e) {
      print("Error fetching reminders: $e");
    }
    return [];
  }

  Future<bool> deleteReminder(String userId, String plateNo, String type) async {
    try {
      final qs = await _remindersCollection
          .where('userId', isEqualTo: userId)
          .where('plateNo', isEqualTo: plateNo)
          .where('type', isEqualTo: type)
          .limit(1)
          .get();
      if (qs.docs.isNotEmpty) {
        await qs.docs.first.reference.delete();
        return true;
      }
    } catch (e) {
      print("Error deleting reminder: $e");
    }
    return false;
  }

  Future<Reminder?> getReminder(String userId, String plateNo, String type) async {
    try {
      final qs = await _remindersCollection
          .where('userId', isEqualTo: userId)
          .where('plateNo', isEqualTo: plateNo) // NEW
          .where('type', isEqualTo: type)
          .limit(1)
          .get();
      return qs.docs.isNotEmpty ? qs.docs.first.data() : null;
    } catch (e) {
      print("Error getting reminder: $e");
    }
    return null;
  }
}
