import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_assignment/core/theme/app_decoration.dart';
import 'package:mobile_app_assignment/model/service.dart';
import 'package:mobile_app_assignment/services/stripe_service.dart';
import 'package:mobile_app_assignment/widgets/appbar_widget.dart';
import 'package:mobile_app_assignment/widgets/app_button_widget.dart';
import 'package:mobile_app_assignment/widgets/service_item.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../provider/navigation_provider.dart';
import 'custom_widgets/ui_helper.dart';

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
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColor.darkCharcoal,
              ),
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
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkCharcoal,
                        fontSize: 14,
                      ),
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
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkCharcoal,
                        fontSize: 14,
                      ),
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
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkCharcoal,
                    fontSize: 14,
                  ),
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
  final Service service;
  const PaymentView({super.key, required this.service});

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
            ServiceItem(service: widget.service, inProgress: null),
            Padding(padding: EdgeInsets.only(top: 20)),
            PaymentMethodItem(),
            Padding(padding: EdgeInsets.only(top: 20)),
            AppButtonWidget(
              text: "Pay",
              onPressed: () async {
                final currentContext = context;
                await StripeService.instance.makePayment(
                  widget.service.fee!.toInt(),
                );
                if (currentContext.mounted) {
                  UiHelper.showSnackBar(
                    currentContext,
                    "Thank you for your payment!",
                    isError: false,
                  );

                  Navigator.pop(currentContext, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
