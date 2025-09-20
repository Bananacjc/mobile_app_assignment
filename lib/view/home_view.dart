import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/theme/app_colors.dart';
import '../widgets/navbar_widget.dart';
import '../model/global_user.dart';

class HomeView extends StatelessWidget {

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${GlobalUser.user?.email ?? 'Guest'}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "UID: ${GlobalUser.user?.uid ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.slateGray,
              ),
            ),
          ],
        ),
    );
  }

}