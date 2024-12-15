import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int _userId =0;
  String _role = '';

  int get userId => _userId;
  String get role => _role;

  void setUser(int userId, String role) {
    _userId = userId;
    _role = role;
    notifyListeners();
  }
}
