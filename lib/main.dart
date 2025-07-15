import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './core/theme/app_colors.dart';
import './view/service_view.dart';
import './view/home_view.dart';
import './view/profile_view.dart';

void main() {
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
  int _currentIndex = 1;
  String? _title;

  @override
  void initState() {
    super.initState();
    _title = 'Good Morning';
  }

  final List<Widget> _pages = [ServiceView(), HomeView(), ProfileView()];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title!, style: GoogleFonts.inter(fontSize: 20))),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Service'),
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
