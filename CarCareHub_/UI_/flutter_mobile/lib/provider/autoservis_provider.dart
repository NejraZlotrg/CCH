import 'dart:convert';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class AutoservisProvider extends BaseProvider<Autoservis> {
  AutoservisProvider() : super("api/Autoservis"); // izmjena 16.9

  @override
  Autoservis fromJson(data) {
    return Autoservis.fromJson(data);
  }

  Future<List<Autoservis>> getAutoservisById(int id) async {
    return await getById(
        id); // Pozivanje funkcije getById iz osnovnog provider-a
  }

  Future<int?> getIdByUsernameAndPassword(
      String username, String password) async {
    try {
      // Kreiraj URL koristeći buildUrl metodu
      String url = buildUrl("get-id?username=$username&password=$password");

      // Pošaljite POST zahtev sa korisničkim imenom i lozinkom
      final response = await http.post(
        Uri.parse(url), // Koristi URL generisan iz buildUrl
        headers: {
          "Content-Type": "application/json", // Potrebno za JSON podatke
        },
        body: jsonEncode({
          "username": username,
          "password": password, // Poslati oba polja (username i password)
        }),
      );

      // Proverite statusni kod odgovora i parsirajte ID ako je uspešno
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']; // Pošaljite ID korisnika
      } else {
        // Ako odgovor nije 200, vrati null
        return null;
      }
    } catch (e) {
      // Ako dođe do greške u API pozivu, ispisivanje greške
      return null;
    }
  }

  @override
  Future<Autoservis> getSingleById(int id) async {
    // Koristi buildUrl metodu za generisanje URL-a
    String url = buildUrl('/AutoservisGetByID/$id'); // Dodajemo ID u URL

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
      // Koristi buildUrl metodu za generisanje URL-a
      String url = buildUrl('/autoservis/check-username/$username');

      final response = await http.get(
        Uri.parse(url),
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
      return false;
    }
  }

  /// Dobavljanje ID-a na osnovu korisničkog imena i lozinke
  Future<bool?> getVidljivoByUsernameAndPassword(
      String username, String password) async {
    try {
      // Kreiraj URL koristeći buildUrl metodu
      String url =
          buildUrl('get-vidljivo?username=$username&password=$password');

      final response = await http.post(
        Uri.parse(url), // Koristi URL generisan iz buildUrl
        headers: {
          "Content-Type": "application/json", // Potrebno za JSON podatke
        },
        body: jsonEncode({
          "username": username,
          "password": password, // Poslati oba polja (username i password)
        }),
      );

      // Proverite statusni kod odgovora i parsirajte ID ako je uspešno
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vidljivo']; // Pošaljite ID korisnika
      } else {
        // Ako odgovor nije 200, vrati null
        return null;
      }
    } catch (e) {
      // Ako dođe do greške u API pozivu, ispisivanje greške
      return null;
    }
  }
}
