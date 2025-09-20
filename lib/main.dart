import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'core/theme/app_colors.dart';
import 'view/login_view.dart';
import 'view/home_view.dart';            // only if you need direct access
import 'view/service_view.dart';
import 'view/profile_view.dart';
import 'widgets/navbar_widget.dart';
import 'model/global_user.dart';
import 'provider/navigation_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColor.primaryGreen,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColor.primaryGreen,
            secondary: AppColor.accentMint,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColor.primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            labelStyle: const TextStyle(color: AppColor.primaryGreen),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColor.primaryGreen,
            selectionColor: AppColor.primaryGreen,
            selectionHandleColor: AppColor.primaryGreen,
          ),
        ),
        home: const _AuthGate(),   // <- decide LoginView vs MainLayout here
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColor.softWhite,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;
        if (user == null) {
          GlobalUser.logout();          // keep your global in sync
          return const LoginView();      // NOT logged in -> Login
        } else {
          GlobalUser.user = user;        // logged in -> your app
          return const MainLayout();
        }
      },
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final size = MediaQuery.of(context).size;
    final pages = [const ServiceView(), const HomeView(), const ProfileView()];

    return Scaffold(
      backgroundColor: AppColor.softWhite,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: NavbarWidget(
        size: size,
        currentIndex: navigationProvider.currentIndex,
        onTap: (index) => navigationProvider.changeTab(index),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: navigationProvider.showFullPage
                  ? navigationProvider.fullPage!
                  : pages[navigationProvider.currentIndex],
            ),
          ],
        ),
      ),
    );
  }
}
