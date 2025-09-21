import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../provider/navigation_provider.dart';
import '../services/account_service.dart';
import 'custom_widgets/ui_helper.dart';


class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  AccountViewState createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, bool> _isEditing = {
    'firstName': false,
    'lastName': false,
    'email': false,
    'password': false,
  };

  bool _showPassword = false;
  File? _profileImage;
  final AccountService _accountService = AccountService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _toggleEdit(String field) {
    setState(() {
      _isEditing[field] = !_isEditing[field]!;
    });
  }

  Future<void> _loadUserData() async {
    final data = await _accountService.loadUserData();
    setState(() {
      _firstNameController.text = data["firstName"];
      _lastNameController.text = data["lastName"];
      _emailController.text = data["email"];
      _passwordController.text = data["password"];
      _profileImage = data["profileImage"];
    });
  }

  Future<void> _pickImage() async {
    final newImage = await _accountService.pickAndSaveImage();
    if (newImage != null) {
      setState(() => _profileImage = newImage);

      UiHelper.showSnackBar(context, 'Profile picture updated successfully!', isError: false);
    }
  }

  Future<void> _saveField(String field) async {
    final data = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'profileImage': _profileImage,
    };

    try {
      final changed = await _accountService.saveField(field, data);
      setState(() => _isEditing[field] = false);

      if (changed) {
        UiHelper.showSnackBar(context, '$field updated successfully!', isError: false);
      }
    } catch (e) {
      UiHelper.showSnackBar(context, 'Failed to update $field: $e', isError: true);
    }
  }

  Widget _buildEditableField(
      String field,
      String label,
      TextEditingController controller, {
        bool isPassword = false,
      }) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: AppColor.slateGray)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _isEditing[field]!
                      ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          obscureText: isPassword && !_showPassword,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF10B981)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF10B981)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            suffixIcon: isPassword
                                ? IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            )
                                : null,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColor.slateGray,
                          ),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _saveField(field),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                      : Text(
                    isPassword ? '••••••••' : controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.slateGray,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleEdit(field),
                  icon: Icon(Icons.edit, size: 16, color: AppColor.slateGray),
                ),
              ],
            ),
            Container(
              height: 1,
              color: Colors.grey[100],
              margin: const EdgeInsets.only(top: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: AppColor.primaryGreen,
          toolbarHeight: 80,
          titleSpacing: 0,
          leadingWidth: 56,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.softWhite),
            onPressed: () => navigationProvider.goBack(),
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "My Account",
              style: TextStyle(
                color: AppColor.softWhite,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile image
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    width: double.infinity,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.amber[100],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                            child: _profileImage == null
                                ? Icon(Icons.person,
                                size: 40, color: Colors.grey[600])
                                : null,
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Editable fields
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildEditableField(
                            'firstName', 'First Name', _firstNameController),
                        _buildEditableField(
                            'lastName', 'Last Name', _lastNameController),
                        _buildEditableField(
                            'email', 'Email', _emailController),
                        _buildEditableField(
                            'password', 'Password', _passwordController,
                            isPassword: true),
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Text('V0.0.1',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text('©2025 Greenstem. All Rights Reserved.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}