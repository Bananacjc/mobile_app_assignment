import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_app_assignment/view/custom_widgets/ui_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'core/theme/app_colors.dart';
import 'view/login_view.dart';
import 'view/home_view.dart';
import 'view/service_view.dart';
import 'view/profile_view.dart';
import 'widgets/navbar_widget.dart';
import 'model/global_user.dart';
import 'provider/navigation_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await _stripeSetup();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

Future<void> _stripeSetup() async {
  Stripe.publishableKey = dotenv.get('STRIPE_PUBLISHABLE_KEY');
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
          fontFamily: GoogleFonts.inter().fontFamily,
          textTheme: GoogleFonts.interTextTheme(),
          primaryTextTheme: GoogleFonts.interTextTheme(),

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
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.softWhite,
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: GoogleFonts.inter(
              color: AppColor.softWhite,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  Future<bool> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_email') && prefs.containsKey('saved_password')) {
      String email = prefs.getString('saved_email')!;
      String password = prefs.getString('saved_password')!;

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        GlobalUser.user = userCredential.user;
        return true;
      } catch (e) {
        // Failed auto-login; clear saved creds
        prefs.remove('saved_email');
        prefs.remove('saved_password');
        return false;
      }
    }
    return false;
  }


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
          GlobalUser.logout(); // keep your global in sync
          return const LoginView(); // NOT logged in -> Login
        } else {
          GlobalUser.user = user; // logged in -> your app
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


