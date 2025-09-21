import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<bool> makePayment(int amount) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(
        amount,
        "myr",
      );
      if (paymentIntentClientSecret! == null) return false;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Car Service",
        ),
      );
      return await _processPayment();
    } catch (e) {
      print(e);
    }
    return false;
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
  }

  Future<bool> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      print("Error process payment: $e");
    }
    return false;
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer ${dotenv.get("STRIPE_SECRET_KEY")}",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
