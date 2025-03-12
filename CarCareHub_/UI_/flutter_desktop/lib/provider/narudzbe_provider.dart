import 'dart:convert';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("api/narudzba");

  @override
  Narudzba fromJson(data) {
    return Narudzba.fromJson(data);
  }

  /// Funkcija za potvrdu narudžbe (označavanje kao završene)
Future<Narudzba> potvrdiNarudzbu(int narudzbaId) async {
  String url = buildUrl("/$narudzbaId/potvrdi"); // API endpoint
  Uri uri = Uri.parse(url);

  // Ispisivanje URL-a i status koda
  print("Request URL: $url");

  Map<String, String> headers = createHeaders();

  try {
    // Send a PUT request to the API
    http.Response response = await http.put(uri, headers: headers);

    // Ispisivanje status koda i tijela odgovora
    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    // Check if the response is successful (status code 200 OK)
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      Narudzba narudzba = Narudzba.fromJson(data);
      return narudzba; // Return the updated Narudzba object
    } else {
      throw Exception('Greška: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    // Ako dođe do greške u slanju zahtjeva
    print("Greška pri slanju zahtjeva: $error");
    throw Exception('Greška pri slanju zahtjeva: $error');
  }
}

Future<SearchResult<Narudzba>> getNarudzbePoUseru(int id) async {
    String url = buildUrl("/$id/GetPoUseru"); // API endpoint za pretragu narudžbi korisnika
    Uri uri = Uri.parse(url);

    // Ispisivanje URL-a i status koda
    print("Request URL: $url");

    Map<String, String> headers = createHeaders();

    try {
      // Send a GET request to the API
      http.Response response = await http.get(uri, headers: headers);

      // Ispisivanje status koda i tijela odgovora
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if the response is successful (status code 200 OK)
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SearchResult<Narudzba> narudzbe = SearchResult<Narudzba>();
              for (var item in data) {
        narudzbe.result.add(fromJson(item));
      }
        return narudzbe; // Return the list of Narudzba objects
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      // Ako dođe do greške u slanju zahtjeva
      print("Greška pri slanju zahtjeva: $error");
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }
}
