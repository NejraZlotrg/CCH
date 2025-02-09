import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
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


    // Dodajemo custom funkciju za sakrivanje proizvoda
  Future<Product> activateProduct(int id) async {
    String url = "${BaseProvider.baseURL}$endpoint/$id/activate"; // Koristimo generičku putanju iz BaseProvider-a
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

// Future<SearchResult<Product>> getForUsers({dynamic filter}) async {
//   try {
//     String url = "${BaseProvider.baseURL}api/proizvodi/GetForUsers";

//     Ako postoje filter parametri, dodaj ih u URL
//     if (filter != null) {
//       String queryString = Uri(queryParameters: Map<String, String>.from(filter)).query;
//       url = "$url?$queryString";
//     }

//     Uri uri = Uri.parse(url);
//     var response = await http.get(uri, headers: createHeaders());

//     if (isValidResponse(response)) {
//       var data = jsonDecode(response.body);

//       SearchResult<Product> result = SearchResult<Product>();
//       result.count = data['count'];

//       for (var item in data['result']) {
//         result.result.add(fromJson(item));
//       }

//       return result;
//     } else {
//       throw Exception("Nevalidan odgovor sa servera (status: ${response.statusCode})");
//     }
//   } catch (e) {
//     print("Greška u getForUsers: $e");
//     throw Exception("Neuspelo dobijanje podataka za korisnike");
//   }
// }

ovo u komentaru sretii 
  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}