import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/feedback.dart';

class FeedbackService {
  final CollectionReference<Feedback> _feedbacksCollection = FirebaseFirestore.instance
      .collection('feedbacks')
      .withConverter(fromFirestore: Feedback.fromFirestore, toFirestore: (Feedback feedback, _) => feedback.toFirestore());

  Future<DocumentReference<Feedback>?> addFeedback(Feedback feedback) async {
    try{
      return await _feedbacksCollection.add(feedback);
    } catch (e) {
      print("Error adding payment: $e");
      return null;
    }
  }

  Future<Feedback?> getFeedback(String serviceId) async {
    try{
      final querySnapshot = await _feedbacksCollection.where('serviceId', isEqualTo: serviceId).get();
      if(querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs[0].data();
      }
    } catch (e) {
      print("Error adding payment: $e");
    }
    return null;
  }

  Future<bool> updateFeedback(Feedback feedback) async {
    try{
      final querySnapshot = await _feedbacksCollection.where('serviceId', isEqualTo: feedback.serviceId).get();
      if(querySnapshot.docs.isNotEmpty){
        _feedbacksCollection.doc(querySnapshot.docs[0].id).set(feedback, SetOptions(merge: true));
        return true;
      }
    } catch (e) {
      print("Error adding payment: $e");
    }
    return false;
  }
}