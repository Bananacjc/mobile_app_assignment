import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'custom_widgets/navbar_widget.dart';

class ProfileView extends StatelessWidget {

  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Center(
      child: Text("Profile View"),
    );
  }
}