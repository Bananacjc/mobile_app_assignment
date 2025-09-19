import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_assignment/model/payment.dart';

class PaymentService {
  final CollectionReference<Payment> _paymentsCollection = FirebaseFirestore.instance
      .collection('payments')
      .withConverter(fromFirestore: Payment.fromFirestore, toFirestore: (Payment payment, _) => payment.toFirestore());

  Future<DocumentReference<Payment>?> addPaymentMethod(Payment payment) async {
    try {
      return await _paymentsCollection.add(payment);
    } catch (e) {
      print("Error adding payment: $e");
      return null;
    }
  }

  Future<bool> updatePayment(Payment payment) async {
    try{
      final querySnapshot = await _paymentsCollection
                                    .where('userId', isEqualTo: payment.userId)
                                    .where('type', isEqualTo: payment.type)
                                    .limit(1)
                                    .get();

      if(querySnapshot.docs.isNotEmpty){
        await _paymentsCollection.doc(querySnapshot.docs[0].id).set(payment, SetOptions(merge: true));
        return true;
      }
      return false;
    } catch (e) {
      print("Error adding payment: $e");
      return false;
    }
  }
}