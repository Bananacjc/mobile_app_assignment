import 'package:flutter/material.dart';
import 'package:mobile_app_assignment/core/theme/app_colors.dart';

class AppDecoration {
  static BoxDecoration get boxDecoration => BoxDecoration(
    color: AppColor.softWhite,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [BoxShadow(color: AppColor.darkCharcoal.withAlpha(63), blurRadius: 10, offset: const Offset(0, 0))],
  );

  static double get maxWidthFactor => 0.93;
}


