import 'dart:convert';

import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;


class KlijentProvider extends BaseProvider<Klijent> {
  KlijentProvider(): super("api/klijent");

  @override
  Klijent fromJson(data) {
    // TODO: implement fromJson
    return Klijent.fromJson(data);
  }
 Future<List<Klijent>> getKorpaById(int id) async {
    return await getById(id); // Pozivanje funkcije getById iz osnovnog provider-a
  }
  Future<int?> getIdByUsernameAndPassword(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:7209/api/klijent/get-id?username=$username&password=$password'),  // Tačan API endpoint
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
  @override
  Future<Klijent> getSingleById(int id) async {
    String url = "http://localhost:7209/api/klijent/KlijentiGetByID/$id"; // Dodajemo ID u URL

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data); // Vraća jedan objekat tipa T
    } else {
      throw Exception("Unknown error");
    }
  }
  
Future<bool> checkUsernameExists(String username) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:7209/api/klijent/check-username/$username'),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] as bool;
    } else {
      return false;
    }
  } catch (e) {
    print('Error checking username: $e');
    return false;
  }
}
}