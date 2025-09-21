import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../provider/navigation_provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool showAppBar;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed; // Make this required or provide default

  const AppBarWidget({
    this.showAppBar = true,
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    
    return showAppBar ? AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: AppColor.softWhite,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      leading: showBackButton
          ? Padding(
        padding: EdgeInsets.only(left: 10, top: 20),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.softWhite),
          onPressed: onBackPressed ?? () {
            if(navigationProvider.showFullPage) {
              navigationProvider.goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      )
          : null,
      backgroundColor: AppColor.primaryGreen,
    ): const SizedBox.shrink();
  }
}
