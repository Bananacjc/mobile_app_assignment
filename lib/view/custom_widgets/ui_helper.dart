import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// A utility class for showing common UI elements.
///
/// This class contains static methods that can be called from anywhere
/// in the app to display UI components like SnackBars or Dialogs.
class UiHelper {
  // A private constructor prevents this class from being instantiated.
  // We only want to use its static methods.
  UiHelper._();

  /// Displays a customizable SnackBar.
  ///
  /// [context] is the BuildContext from which to find the ScaffoldMessenger.
  /// [message] is the text content to display.
  /// [isError] determines the background color of the SnackBar.
  static void showSnackBar(
      BuildContext context,
      String message, {
        bool isError = true,
      }) {
    // Determine the background color based on whether it's an error message.
    final Color backgroundColor = isError ? Colors.redAccent : Colors.green;
    final Size size = MediaQuery.of(context).size;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: AppColor.softWhite, fontSize: 16, fontWeight: FontWeight.w400)),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          // Adjust margin to appear above the keyboard, if it's open.
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16,
          right: 16,
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(milliseconds: 2000),
        elevation: 6.0,
      ),
    );


  }
}