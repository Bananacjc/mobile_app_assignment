import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/navbar_widget.dart';
import './core/theme/app_colors.dart';
import './view/service_view.dart';
import './view/home_view.dart';
import './view/profile_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Mobile Application',
      home: MainLayout(title: ''),
    );
  }
}

class MainLayout extends StatefulWidget {
  final String title;

  const MainLayout({super.key, required this.title});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1; // Home
  String? _title;

  final List<Widget> _pages = [ServiceView(), HomeView(), ProfileView()];

  @override
  void initState() {
    super.initState();
    _title = 'Good Morning';
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.softWhite,
      body: Stack(
        children: [
          Positioned.fill(child: _pages[_currentIndex]),
          NavbarWidget(size: size, currentIndex: _currentIndex, onTap: _onTap)
        ],
      )

    );
  }
}
