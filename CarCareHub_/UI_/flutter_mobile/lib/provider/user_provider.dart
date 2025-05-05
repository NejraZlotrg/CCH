import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int _userId = 0;
  String _role = '';
  String _username = '';
  String adrresa = '';
  int telefon = 0;
  int get userId => _userId;
  String get role => _role;
  String get username => _username;

  void setUser(int userId, String role, String username) {
    _userId = userId;
    _role = role;
    _username = username;

    notifyListeners();
  }
}
