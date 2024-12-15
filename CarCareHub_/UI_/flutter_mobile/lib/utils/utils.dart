import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authorization {
  static String? username;
  static String? password;
  static int? zaposlenikId; // ID za zaposlenika
  static int? firmaAutodijelovaId; // ID za firmu autodijelova
  static int? autoservisId; // ID za autoservis
  static int? klijentId; // ID za klijenta
  static String? nazivUloge; // Naziv uloge (Zaposlenik, FirmaAutodijelova, Autoservis, Klijent)
}

// Funkcija za dekodiranje Base64 stringa u sliku
Image imageFromBase64String(String base64Image) {
  return Image.memory(base64Decode(base64Image));
}

// Funkcija za formatiranje broja
String formatNumber(dynamic number) {
  var f = NumberFormat('#,##0.00'); // Postavlja format sa dve decimale
  if (number == null) {
    return "";
  }
  return f.format(number);
}

// Funkcija za pohranu korisničkih podataka
Future<void> saveUserCredentials(String username, String password, String userId, String nazivUloge) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  prefs.setString('password', password);
  prefs.setString('ulogaNaziv', nazivUloge); // Pohranjujemo naziv uloge
  
  // Pohranjujemo ID na temelju uloge
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

// Funkcija za učitavanje korisničkih podataka
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

// Funkcija za dohvat ID-a na temelju uloge korisnika
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

// Funkcija za dohvat naziva uloge trenutnog korisnika
Future<String?> getLoggedInUlogaNaziv() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('ulogaNaziv');
}
