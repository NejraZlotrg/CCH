import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("api/proizvodi");

  Future<int> getCurrentNarudzbaId() async {
    final url = Uri.parse('https://localhost:7209/api/narudzba/current');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['narudzbaId']; // Pretpostavimo da API vraća narudzbaId
      } else if (response.statusCode == 404) {
        return -1; // Nema aktivne narudžbe
      } else {
        throw Exception('Greška pri dobavljanju trenutne narudžbe');
      }
    } catch (error) {
      throw Exception('Došlo je do greške: $error');
    }
  }

Future<Map<String, dynamic>?> getActiveOrder() async {
  final url = Uri.parse('https://localhost:7209/api/narudzba'); // Endpoint za sve narudžbe
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> orders = jsonDecode(response.body);
      // Filtriraj aktivne narudžbe
      final activeOrder = orders.firstWhere(
          (order) => order['zavrsenaNarudzba'] == false,
          orElse: () => null); // Ako nema aktivne narudžbe, vrati null
      return activeOrder;
    } else {
      throw Exception('Greška pri dobavljanju narudžbi');
    }
  } catch (error) {
    throw Exception('Došlo je do greške: $error');
  }
}



  Future<int> createNewNarudzba() async {
    final url = Uri.parse('https://localhost:7209/api/narudzba');
    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['narudzbaId']; // Pretpostavimo da API vraća kreirani narudzbaId
      } else {
        throw Exception('Greška pri kreiranju nove narudžbe');
      }
    } catch (error) {
      throw Exception('Došlo je do greške: $error');
    }
  }

  Future<void> addNarudzbaStavka(Map<String, dynamic> request) async {
    int narudzbaId = await getCurrentNarudzbaId();

    if (narudzbaId == -1) {
      narudzbaId = await createNewNarudzba(); // Kreiraj novu narudžbu ako ne postoji
    }

    final url = Uri.parse('https://localhost:7209/api/narudzbaStavka');
    request['narudzbaId'] = narudzbaId; // Dodaj narudzbaId u request

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Greška pri dodavanju narudžbe: ${response.body}');
      }
    } catch (error) {
      throw Exception('Došlo je do greške: $error');
    }
  }

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}
