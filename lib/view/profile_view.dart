import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../model/global_user.dart';
import '../services/auth_service.dart';
import '../view/login_view.dart';
import '../core/theme/app_colors.dart';
import '../view/vehicle_view.dart';
import '../provider/navigation_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _name = "Loading...";
  String _email = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _name = "${GlobalUser.user?.displayName ?? 'Guest'}";
      _email = "${GlobalUser.user?.email ?? 'No Email'}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: AppColor.softWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: AppColor.primaryGreen,
          toolbarHeight: 80,
          titleSpacing: 0,
          title: const Padding(
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
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.darkCharcoal.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey[300],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email,
                                style: const TextStyle(
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

                  _buildMenuItem('My Account', Icons.chevron_right),
                  _buildDivider(),

                  // VEHICLE —> open full-page VehicleView
                  _buildMenuItem(
                    'Vehicle',
                    Icons.chevron_right,
                    onTap: () {
                      navigationProvider.showFullPageContent(VehicleView());
                    },
                  ),
                  _buildDivider(),

                  _buildMenuItem('Payment', Icons.chevron_right),
                  _buildDivider(),
                  _buildMenuItem('FAQ', Icons.chevron_right),
                  _buildDivider(),
                  _buildMenuItem('T&C', Icons.chevron_right),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Log out?'),
                              content: const Text(
                                'You will be returned to the login screen.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Log Out'),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          try {
                            await AuthService().signOut();
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginView(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout failed: $e')),
                            );
                          }
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
            // Footer
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text(
                    'v0.0.1',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.darkCharcoal,
                    ),
                  ),
                  SizedBox(height: 4),
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

  // let this take an optional onTap
  Widget _buildMenuItem(
    String title,
    IconData trailingIcon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppColor.darkCharcoal),
      ),
      trailing: Icon(trailingIcon, color: AppColor.darkCharcoal, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColor.softWhite,
      indent: 20,
      endIndent: 20,
    );
  }
}
