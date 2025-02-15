import 'dart:convert';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseURL; // Bazni URL aplikacije
  final String _endpoint;  // Endpoint za specifične API zahtjeve

  BaseProvider(String endpoint) 
      : _endpoint = endpoint {
    //_baseURL = const String.fromEnvironment("baseURL", defaultValue: "http://localhost:7209/"); // Bazni URL
    const apiHost = String.fromEnvironment("API_HOST", defaultValue: "10.0.2.2");
    const apiPort = String.fromEnvironment("API_PORT", defaultValue: "7209");
    _baseURL= "http://$apiHost:$apiPort";
  }

  
String buildUrl(String path) {
  // Osiguravanje da path počinje sa "/"
  if (!path.startsWith('/')) {
    path = '/$path';
  }

  // Osiguravanje da endpoint nema višak "/" na kraju
  String endpoint = _endpoint.endsWith('/') ? _endpoint.substring(0, _endpoint.length - 1) : _endpoint;

  print(_baseURL);

  return "$_baseURL$endpoint$path";
}

  Future<SearchResult<T>> get({dynamic filter}) async {
    String url = "$_baseURL$_endpoint";

    if (filter != null) {
      String queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      SearchResult<T> result = SearchResult<T>();
      result.count = data['count'];

      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }



  // Implementacija getById
  Future<List<T>> getById(int id) async {
    String url = "$_baseURL$_endpoint/$id"; // Dodajemo ID u URL

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<T> resultList = [];

      // Pretvaramo svaki element u model tipa T
      for (var item in data) {
        resultList.add(fromJson(item));
      }

      return resultList;
    } else {
      throw Exception("Unknown error");
    }
  }

  // Validacija HTTP odgovora
  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      print(response.body);
      throw Exception("Something bad happened, please try again");
    }
  }

  // Kreiranje headera s osnovnom autorizacijom
  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
  }


  // Generisanje query stringa iz mape parametara
  String getQueryString(Map params, {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

  // Metoda za unos novih podataka u API
  Future<T> insert(dynamic request) async {
    String url = "$_baseURL$_endpoint";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    String jsonRequest = jsonEncode(request);
    http.Response response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  // Metoda za ažuriranje postojećih podataka u API-ju
  Future<T> update(int id, [dynamic request]) async {
    String url = "$_baseURL$_endpoint/$id";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    String jsonRequest = jsonEncode(request);
    http.Response response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<void> delete(int id) async {
  String url = "$_baseURL$_endpoint/$id";
  Uri uri = Uri.parse(url);
  Map<String, String> headers = createHeaders();

  http.Response response = await http.delete(uri, headers: headers);

  if (isValidResponse(response)) {
    // Successful deletion, no content to return
    return;
  } else {
    throw Exception("Unknown error");
  }
}

  // Metoda koju moraš implementirati u naslijeđenoj klasi
  T fromJson(data) {
    throw Exception("Method not implemented");
  }
}
