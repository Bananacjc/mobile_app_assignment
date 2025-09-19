import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_assignment/core/theme/app_decoration.dart';

import '../core/theme/app_colors.dart';

class AppButtonWidget extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  const AppButtonWidget({super.key, required this.text, this.textColor, this.backgroundColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(Size(size.width * AppDecoration.maxWidthFactor, 40)),
        backgroundColor: WidgetStateProperty.all(backgroundColor ?? AppColor.accentMint),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        elevation: WidgetStateProperty.all(0),
      ),
      onPressed: onPressed,
      child: Text(text, style: GoogleFonts.inter(color: textColor ?? AppColor.softWhite, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
