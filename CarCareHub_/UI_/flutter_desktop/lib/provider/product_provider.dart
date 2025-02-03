import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("api/proizvodi");

  // Dodajemo custom funkciju za sakrivanje proizvoda
  Future<Product> hideProduct(int id) async {
    String url = "${BaseProvider.baseURL}$endpoint/$id/hide"; // Koristimo generičku putanju iz BaseProvider-a
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška pri sakrivanju proizvoda (status: ${response.statusCode})");
    }
  }

  // // Opcionalno: Dodajte i funkciju za prikaz proizvoda ako je potrebno
  // Future<Product> showProduct(int id) async {
  //   String url = "$_baseURL$_endpoint/$id/show";
  //   Uri uri = Uri.parse(url);
  //   Map<String, String> headers = createHeaders();

  //   http.Response response = await http.put(uri, headers: headers);

  //   if (isValidResponse(response)) {
  //     var data = jsonDecode(response.body);
  //     return fromJson(data);
  //   } else {
  //     throw Exception("Greška pri prikazivanju proizvoda (status: ${response.statusCode})");
  //   }
  // }

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}