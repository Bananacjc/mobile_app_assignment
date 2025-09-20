// provider/navigation_provider.dart
import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 1;
  Widget? _fullPage; // For full page content
  bool _showFullPage = false;

  int get currentIndex => _currentIndex;
  Widget? get fullPage => _fullPage;
  bool get showFullPage => _showFullPage;

  void changeTab(int index) {
    _currentIndex = index;
    _showFullPage = false;
    _fullPage = null;
    notifyListeners();
  }

  void showFullPageContent(Widget page) {
    _fullPage = page;
    _showFullPage = true;
    notifyListeners();
  }

  void goBack() {
    _showFullPage = false;
    _fullPage = null;
    notifyListeners();
  }
}