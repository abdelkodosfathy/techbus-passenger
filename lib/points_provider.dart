import 'package:flutter/material.dart';

class PointsProvider with ChangeNotifier {
  int _points = 0;

  int get points => _points;

  void setPoints(int points) {
    _points = points;
      print("Trying to add: $points");
      notifyListeners();
      print("Points updated to: $_points");
  }

  // Initialize points from local storage
  void initializePoints(int points) {
    _points = points;
    notifyListeners();
  }
}
