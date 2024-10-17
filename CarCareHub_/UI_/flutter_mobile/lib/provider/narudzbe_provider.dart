import 'dart:convert';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("api/narudzba");

  @override
  Narudzba fromJson(data) {
    return Narudzba.fromJson(data);
  }

  // Kreiranje nove narudžbe
  Future<void> createNewNarudzba() async {
    await insert({
      'datumNarudzbe': DateTime.now().toIso8601String(),
      'datumIsporuke': null,
      'zavrsenaNarudzba': false,
      'popustId': 0,
      'ukupnaCijenaNarudzbe': null,
    });
  }
}
