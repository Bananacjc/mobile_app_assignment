import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_assignment/core/theme/app_decoration.dart';
import 'package:mobile_app_assignment/services/stripe_service.dart';
import 'package:mobile_app_assignment/widgets/appbar_widget.dart';
import 'package:mobile_app_assignment/widgets/app_button_widget.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../provider/navigation_provider.dart';

class ServiceItem extends StatelessWidget {
  const ServiceItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        decoration: AppDecoration.boxDecoration,
        width: 350,
        height: 104,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: AppColor.primaryGreen, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.add, color: AppColor.softWhite, size: 36),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      width: 100,
                      child: Text("Brake Oil Service", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, right: 10),
                      child: Text("IN INSPECTION", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 10),
                      child: Container(
                        //color: AppColor.darkCharcoal,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColor.darkCharcoal,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          "BFP 1975",
                          style: TextStyle(color: AppColor.softWhite, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(
              indent: 10, // adjust later
              endIndent: 10,
              color: AppColor.slateGray.withAlpha(63),
              thickness: 1,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: const Text(
                  "RM 200.00",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColor.accentMint, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodItem extends StatelessWidget {
  const PaymentMethodItem({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      decoration: AppDecoration.boxDecoration,
      width: size.width * AppDecoration.maxWidthFactor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Method",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColor.darkCharcoal),
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, color: AppColor.accentMint),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Text(
                      "Credit / Debit Card",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColor.darkCharcoal, fontSize: 14),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColor.slateGray),
              ],
            ),
            Divider(color: AppColor.slateGray.withAlpha(63), thickness: 1),
            Padding(padding: EdgeInsets.only(top: 8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.wallet, color: AppColor.accentMint),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Text(
                      "E-Wallet",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColor.darkCharcoal, fontSize: 14),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColor.slateGray),
              ],
            ),
            Divider(color: AppColor.slateGray.withAlpha(63), thickness: 1),
            Padding(padding: EdgeInsets.only(top: 8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.attach_money, color: AppColor.accentMint),
                Padding(padding: EdgeInsets.only(left: 10)),
                Text(
                  "Cash",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColor.darkCharcoal, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<StatefulWidget> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final String _title = "Payment"; // Default title

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.softWhite,
      appBar: AppBarWidget(title: _title, showBackButton: true),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: 4)),
            ServiceItem(),
            Padding(padding: EdgeInsets.only(top: 20)),
            PaymentMethodItem(),
            Padding(padding: EdgeInsets.only(top: 20)),
            AppButtonWidget(
              text: "Pay",
              onPressed: () {
                StripeService.instance.makePayment(10);
              },
            ),
          ],
        ),
      ),
    );
  }
}
