import 'dart:convert';

import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;


class ZaposlenikProvider extends BaseProvider<Zaposlenik> {
  ZaposlenikProvider():super("/api/zaposlenici");

  @override
  Zaposlenik fromJson(data) {
    // TODO: implement fromJson
    return Zaposlenik.fromJson(data);
  }
   Future<List<Zaposlenik>> getzaposlenikById(int id) async {
    return await getById(id); // Pozivanje funkcije getById iz osnovnog provider-a
  }

  Future<int?> getIdByUsernameAndPassword(String username, String password) async {
  try {
        // Kreiranje punog URL-a koristeći funkciju buildUrl
    String url = buildUrl('/get-id?username=$username&password=$password');
   
    final response = await http.post(
      Uri.parse(url),  // Tačan API endpoint
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

Future<bool?> getVidljivoByUsernameAndPassword(String username, String password) async {
  try {
    String url = buildUrl('/get-vidljivo?username=$username&password=$password');
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['vidljivo'];
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching visibility status: $e');
    return null;
  }
}


//   String url = "";

  @override
  Future<Zaposlenik> getSingleById(int id) async {
    String url = buildUrl('/ZaposleniciGetByID/$id'); // Dodajemo ID u URL

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);
 print("API odgovor: ${response.body}");
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data); // Vraća jedan objekat tipa T
    } else {
      throw Exception("Unknown error");
    }
  }



  Future<bool> checkUsernameExists(String username) async {
  try {
    String url = buildUrl('/check-username/$username');
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    final response = await http.get(uri, headers: headers);

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
