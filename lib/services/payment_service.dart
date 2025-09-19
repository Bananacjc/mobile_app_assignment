import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_app_assignment/model/payment.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_assignment/services/service_service.dart';

class PaymentService {
  final CollectionReference<Payment> _paymentsCollection = FirebaseFirestore.instance
      .collection('payments')
      .withConverter(fromFirestore: Payment.fromFirestore, toFirestore: (Payment payment, _) => payment.toFirestore());
  final ServiceService ss2 = ServiceService();

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
    } catch (e) {
      print("Error updating payment: $e");
    }
    return false;
  }

  Future<List<Payment>> getAllPayment(String userId) async {
    try{
      final querySnapshot = await _paymentsCollection.where('userId', isEqualTo: userId).get();
      if(querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print("Error fetching payment methods: $e");
    }
    return [];
  }

  Future<bool> deletePaymentMethod(String userId, String type) async {
    try{
      final paymentMethod = await _paymentsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .limit(1).get();
      await paymentMethod.docs[0].reference.delete();
      return true;
    } catch (e) {
      print("Error deleting payment: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    try {
      final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
      final secretKey = dotenv.env['STRIPE_SECRET_KEY']!;
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': (amount*100).toString(),
          'currency': 'myr',
          'payment_method_types[]': 'card',
          'payment_method_types[]': 'grabpay',
          'payment_method_types[]': 'alipay',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Fail to make payment $e');
      rethrow;
    }
  }

  Future<bool> makePayment(String serviceId, double amount) async {
    try{
      final paymentIntent = await createPaymentIntent(amount);
      Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Service Payment',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      print("Payment successful");
      // await ss2.updateServiceStatus(serviceId, 'paid');
      return true;
    } catch (e) {
      print("Payment failed: $e");
    }
    return false;
  }
}