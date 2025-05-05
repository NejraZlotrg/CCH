import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("api/proizvodi");

  Future<Product> hideProduct(int id) async {
    String url = "$baseURL$endpoint/$id/hide";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception(
          "Greška pri sakrivanju proizvoda (status: ${response.statusCode})");
    }
  }

  Future<List<Product>> getByFirmaAutodijelovaID(
      int firmaAutodijelovaID) async {
    String url = buildUrl('/GetByFirmaAutodijelovaID/$firmaAutodijelovaID');

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      List<dynamic> data = jsonDecode(response.body)['result'];
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw Exception("Greška pri dohvaćanju proizvoda!");
    }
  }

  Future<Product> activateProduct(int id) async {
    String url = "$baseURL$endpoint/$id/activate";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception(
          "Greška pri sakrivanju proizvoda (status: ${response.statusCode})");
    }
  }

  Future<SearchResult<Product>> getForUsers({dynamic filter}) async {
    String url = "$baseURL$endpoint/GetForUsers";

    if (filter != null) {
      String queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      SearchResult<Product> result = SearchResult<Product>();
      result.count = data['count'];

      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<Product> deleteDraftProduct(int id) async {
    String url = "$baseURL$endpoint/DeleteDraftProizvod?id=$id";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception(
          "Greška pri brisanju draft proizvoda (status: ${response.statusCode})");
    }
  }

  Future<List<Product>> getRecommendations(int proizvodId) async {
    String url = "$baseURL$endpoint/recommend/$proizvodId";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw Exception(
          "Greška pri dohvaćanju preporuka (status: ${response.statusCode})");
    }
  }

  Future<SearchResult<Product>> getForAutoservis(int autoservisID,
      {dynamic filter}) async {
    String url =
        "$baseURL$endpoint/GetForAutoservisSapoputomArtikli/$autoservisID";

    if (filter != null) {
      String queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      SearchResult<Product> result = SearchResult<Product>();
      result.count = data['count'];

      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception(
          "Greška pri dohvaćanju proizvoda za autoservis (status: ${response.statusCode})");
    }
  }

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}
