// widgets/base_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../provider/navigation_provider.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showBackButton;

  const BasePage({super.key, required this.child, this.title = "Page", this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.softWhite,
      body: child,
    );
  }
}
