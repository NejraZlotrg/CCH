import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authorization {
  static String? username;
  static String? password;
  static int? zaposlenikId;
  static int? firmaAutodijelovaId;
  static int? autoservisId;
  static int? klijentId;
  static String? nazivUloge;
}

Image imageFromBase64String(String base64Image) {
  return Image.memory(base64Decode(base64Image));
}

String formatNumber(dynamic number) {
  var f = NumberFormat('#,##0.00');
  if (number == null) {
    return "";
  }
  return f.format(number);
}

Future<void> saveUserCredentials(
    String username, String password, String userId, String nazivUloge) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  prefs.setString('password', password);
  prefs.setString('ulogaNaziv', nazivUloge);

  switch (nazivUloge) {
    case 'zaposlenik':
      prefs.setString('zaposlenikId', userId);
      break;
    case 'firmaAutodijelova':
      prefs.setString('firmaAutodijelovaId', userId);
      break;
    case 'autoservis':
      prefs.setString('autoservisId', userId);
      break;
    case 'klijent':
      prefs.setString('klijentId', userId);
      break;
  }
}

Future<Map<String, String>?> loadUserCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');
  final password = prefs.getString('password');
  final ulogaNaziv = prefs.getString('ulogaNaziv');

  if (username != null && password != null && ulogaNaziv != null) {
    return {
      'username': username,
      'password': password,
      'ulogaNaziv': ulogaNaziv,
    };
  }
  return null;
}

Future<String?> getUserIdByUloga(String ulogaNaziv) async {
  final prefs = await SharedPreferences.getInstance();

  switch (ulogaNaziv) {
    case 'zaposlenik':
      return prefs.getString('zaposlenikId');
    case 'firmaAutodijelova':
      return prefs.getString('firmaAutodijelovaId');
    case 'autoservis':
      return prefs.getString('autoservisId');
    case 'klijent':
      return prefs.getString('klijentId');
    default:
      return null;
  }
}

Future<String?> getLoggedInUlogaNaziv() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('ulogaNaziv');
}
