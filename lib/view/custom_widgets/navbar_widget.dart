import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_assignment/view/profile_view.dart';
import '../../core/theme/app_colors.dart';
import '../home_view.dart';
import '../service_view.dart';

class NavbarWidget extends StatelessWidget {
  final Size size;
  final int currentIndex;
  final Function(int) onTap;

  const NavbarWidget({
    super.key,
    required this.size,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: size.width,
        height: 80,
        color: Colors.white,
        child: Stack(
          children: [
            Center(
              heightFactor: 0.31,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: currentIndex == 1 ? AppColor.accentMint.withAlpha(77) : AppColor.darkCharcoal.withAlpha(77),
                      spreadRadius: 7,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: FloatingActionButton(
                    onPressed: () => onTap(1),
                    backgroundColor: Colors.white,
                    elevation: 0.1,
                    shape: CircleBorder(),
                    child: Icon(Icons.house_outlined, color: currentIndex == 1 ? AppColor.accentMint : AppColor.darkCharcoal, size: 30),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    children: [
                      IconButton(
                        icon: Icon(Icons.build_outlined, color: currentIndex == 0 ? AppColor.accentMint : AppColor.darkCharcoal, size: 30),
                        onPressed: () => onTap(0),
                      ),
                      Text(
                        'Service',
                        style: TextStyle(
                          color: currentIndex == 0 ? AppColor.accentMint : AppColor.darkCharcoal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(width: size.width * 0.20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.account_circle_outlined,
                          color: currentIndex == 2 ? AppColor.accentMint : AppColor.darkCharcoal,
                          size: 30,
                        ),
                        onPressed:  () => onTap(2),
                      ),
                      Text(
                        'Account',
                        style: TextStyle(
                          color: currentIndex == 2 ? AppColor.accentMint : AppColor.darkCharcoal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}