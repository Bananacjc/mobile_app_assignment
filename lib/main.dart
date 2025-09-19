import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_assignment/model/payment.dart';
import 'package:mobile_app_assignment/view/payment_view.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/navbar_widget.dart';
import './core/theme/app_colors.dart';
import './view/service_view.dart';
import './view/home_view.dart';
import './view/profile_view.dart';
import '../provider/navigation_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: MaterialApp(home: MainLayout()),
    );
  }
}

class MainLayout extends StatelessWidget {

  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final Size size = MediaQuery.of(context).size;

    final List<Widget> _pages = [ServiceView(), HomeView(), ProfileView()];

    return Scaffold(
      backgroundColor: AppColor.softWhite,
      body: Stack(
        children: [
          // Show either the full page or the tab content
          Positioned.fill(
            child: navigationProvider.showFullPage
                ? navigationProvider.fullPage!
                : _pages[navigationProvider.currentIndex],
          ),

          // Always show navbar
          NavbarWidget(
            size: size,
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) => navigationProvider.changeTab(index),
          ),
        ],
      ),
    );
  }
}
