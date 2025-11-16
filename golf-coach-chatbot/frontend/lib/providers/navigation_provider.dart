import 'package:flutter/material.dart';

import '../utils/constants.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = NavigationTabs.home;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}

