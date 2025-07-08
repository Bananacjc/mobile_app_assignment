import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/screen_size.dart';

class NavItem {
  final String label;
  final Icon icon;

  NavItem({required this.label, required this.icon});
}

class NavbarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavbarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double h, w;
    h = ScreenSize.height(context);
    w = ScreenSize.width(context);

    final List<Map<String, NavItem>> navItems = [
      {'service': NavItem(label: 'Service', icon: Icon(Icons.build_outlined))},
      {'home': NavItem(label: '', icon: Icon(Icons.house_outlined))},
      {
        'profile': NavItem(
          label: 'Profile',
          icon: Icon(Icons.account_circle_outlined),
        ),
      },
    ];

    return SafeArea(
      child: Container(
        width: w,
        height: 80,
        decoration: BoxDecoration(color: AppColor.softWhite),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }
}
