import 'dart:convert';

import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class FirmaAutodijelovaProvider extends BaseProvider<FirmaAutodijelova> {
  FirmaAutodijelovaProvider():super("api/firmaAutodijelova");

  @override
  FirmaAutodijelova fromJson(data) {
    // TODO: implement fromJson
    return FirmaAutodijelova.fromJson(data);
  }

 Future<int?> getIdByUsernameAndPassword(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:7209/api/firmaAutodijelova/get-id?username=$username&password=$password'),  // Tačan API endpoint
      headers: {
        "Content-Type": "application/json",  // Potrebno za JSON podatke
      },
      body: jsonEncode({
        "username": username,
        "password": password,  // Poslati oba polja (username i password)
      }),
    );

    // Proverite statusni kod odgovora i parsirajte ID ako je uspešno
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];  // Pošaljite ID korisnika
    } else {
      // Ako odgovor nije 200, vrati null
      return null;
    }
  } catch (e) {
    // Ako dođe do greške u API pozivu, ispisivanje greške
    print('Error fetching ID: $e');
    return null;
  }
}

}
