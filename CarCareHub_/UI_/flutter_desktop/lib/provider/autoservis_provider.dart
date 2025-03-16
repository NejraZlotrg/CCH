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
    return await getById(id); // Pozivanje funkcije getById iz osnovnog provider-a
  }

  /// Dobavljanje ID-a na osnovu korisničkog imena i lozinke
 Future<int?> getIdByUsernameAndPassword(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:7209/api/Autoservis/get-id?username=$username&password=$password'),  // Tačan API endpoint
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


Future<Autoservis> getSingleById(int id) async {
    String url = "http://localhost:7209/api/Autoservis/AutoservisGetByID/$id"; // Dodajemo ID u URL

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

}