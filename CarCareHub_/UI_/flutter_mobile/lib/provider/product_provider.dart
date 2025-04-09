import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("/api/proizvodi");


// Dodajemo custom funkciju za sakrivanje proizvoda
  Future<Product> hideProduct(int id) async {
    String url = "$baseURL$endpoint/$id/hide"; // Koristimo generičku putanju iz BaseProvider-a
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

 Future<List<Product>> getByFirmaAutodijelovaID(int firmaAutodijelovaID) async {
    String url = "http://10.0.2.2:7209/api/proizvodi/GetByFirmaAutodijelovaID/$firmaAutodijelovaID";

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      List<dynamic> data = jsonDecode(response.body)['result']; // Uzima listu iz odgovora
      return data.map((item) => fromJson(item)).toList(); // Mapira u listu objekata `Proizvod`
    } else {
      throw Exception("Greška pri dohvaćanju proizvoda!");
    }
  }


    // Dodajemo custom funkciju za sakrivanje proizvoda
  Future<Product> activateProduct(int id) async {
    String url = "$baseURL$endpoint/$id/activate"; // Koristimo generičku putanju iz BaseProvider-a
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


  // Dodajemo custom funkciju za brisanje draft proizvoda
  Future<Product> deleteDraftProduct(int id) async {
    String url = "$baseURL$endpoint/DeleteDraftProizvod?id=$id"; 
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška pri brisanju draft proizvoda (status: ${response.statusCode})");
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
    throw Exception("Greška pri dohvaćanju preporuka (status: ${response.statusCode})");
  }
}

Future<SearchResult<Product>> getForAutoservis(int autoservisID, {dynamic filter}) async {
  // Sastavljanje URL-a za dohvat proizvoda za određeni autoservis
  String url = "$baseURL$endpoint/GetForAutoservisSapoputomArtikli/$autoservisID";

print(url);
  // Ako postoji filter, dodaj ga kao query parametre
  if (filter != null) {
    String queryString = getQueryString(filter);
    url = "$url?$queryString";
  }

  Uri uri = Uri.parse(url);
  Map<String, String> headers = createHeaders();

  // Slanje GET zahtjeva prema serveru
  http.Response response = await http.get(uri, headers: headers);

  // Provjera je li odgovor valjan
  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);

    // Kreiranje rezultata za SearchResult
    SearchResult<Product> result = SearchResult<Product>();
    result.count = data['count']; // Broj ukupnih stavki

    // Mapiranje rezultata u listu objekata Product
    for (var item in data['result']) {
      result.result.add(fromJson(item));
    }

    return result;
  } else {
    throw Exception("Greška pri dohvaćanju proizvoda za autoservis (status: ${response.statusCode})");
  }
}


  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}