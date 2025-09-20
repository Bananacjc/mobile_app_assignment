import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/theme/app_colors.dart';
import '../widgets/navbar_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.softWhite,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            title: Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Text(
                "User Profile",
                style: TextStyle(
                  color: AppColor.softWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            backgroundColor: AppColor.primaryGreen,
          ),
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Main content container
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.darkCharcoal.withOpacity(0.2), // shadow color
                    blurRadius: 12, // softness
                    spreadRadius: 2, // how wide the shadow spreads
                    offset: const Offset(0, 6), // position of shadow (x, y)
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey[300],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/images/profile_placeholder.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Profile Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Qiin Shi Huang',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'qiinshihuang@gmail.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Menu Items
                  _buildMenuItem('My Account', Icons.chevron_right),
                  _buildDivider(),
                  _buildMenuItem('Vehicle', Icons.chevron_right),
                  _buildDivider(),
                  _buildMenuItem('Payment', Icons.chevron_right),
                  _buildDivider(),
                  _buildMenuItem('FAQ', Icons.chevron_right),
                  _buildDivider(),
                  _buildMenuItem('T&C', Icons.chevron_right),

                  // 🚀 Logout button directly below T&C
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle logout
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppColor.softWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Footer (outside container)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text(
                    'v0.0.1',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '©2025 Greenstein. All Rights Reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData trailingIcon) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: AppColor.darkCharcoal,
        ),
      ),
      trailing: Icon(
        trailingIcon,
        color: AppColor.darkCharcoal,
        size: 20,
      ),
      onTap: () {
        // Handle menu item tap
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColor.softWhite,
      indent: 20,
      endIndent: 20,
    );
  }
}