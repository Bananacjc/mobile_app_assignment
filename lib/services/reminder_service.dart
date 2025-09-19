import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/reminder.dart';

class ReminderService {
  final CollectionReference<Reminder> _remindersCollection = FirebaseFirestore.instance
      .collection('reminders')
      .withConverter(fromFirestore: Reminder.fromFirestore, toFirestore: (Reminder reminder, _) => reminder.toFirestore());

  Future<DocumentReference<Reminder>?> addReminder(Reminder reminder) async {
    try {
      return await _remindersCollection.add(reminder);
    } catch (e) {
      print("Error adding reminder: $e");
      return null;
    }
  }

  Future<bool> updateReminder(Reminder reminder) async {
    try{
      final querySnapshot = await _remindersCollection
          .where('userId', isEqualTo: reminder.userId)
          .where('type', isEqualTo: reminder.type)
          .limit(1)
          .get();

      if(querySnapshot.docs.isNotEmpty){
        await _remindersCollection.doc(querySnapshot.docs[0].id).set(reminder, SetOptions(merge: true));
        return true;
      }
    } catch (e) {
      print("Error updating reminder: $e");
    }
    return false;
  }

  Future<List<Reminder>> getAllReminder(String userId) async {
    try{
      final querySnapshot = await _remindersCollection.where('userId', isEqualTo: userId).get();
      if(querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print("Error fetching reminders: $e");
    }
    return [];
  }

  Future<bool> deleteReminder(String userId, String type) async {
    try{
      final reminder = await _remindersCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .limit(1).get();
      await reminder.docs[0].reference.delete();
      return true;
    } catch (e) {
      print("Error deleting reminder: $e");
    }
    return false;
  }
}