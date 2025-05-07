// ignore_for_file: avoid_print, prefer_initializing_formals

import 'dart:convert';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseURL;
  final String endpoint;  

  BaseProvider(String endpoint) 
      : endpoint = endpoint {
    baseURL = const String.fromEnvironment("baseURL", defaultValue: "http://localhost:7209/"); 
  }

   String buildUrl(String path) {
    return "$baseURL$endpoint$path";  
  }
  Future<SearchResult<T>> get({dynamic filter}) async {
    String url = "$baseURL$endpoint";

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

  Future<SearchResult<T>> getAdmin({dynamic filter}) async {
    String url = "$baseURL$endpoint/Admin";

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


  Future<List<T>>  getById(int? id) async {
    String url = "$baseURL$endpoint/$id"; 
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<T> resultList = [];

      for (var item in data) {
        resultList.add(fromJson(item));
      }

      return resultList;
    } else {
      throw Exception("Unknown error");
    }
  }

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

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
  }


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

  Future<T> insert(dynamic request) async {
    String url = "$baseURL$endpoint";
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
  Future<T> update(int id, [dynamic request]) async {
    String url = "$baseURL$endpoint/$id";
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
  String url = "$baseURL$endpoint/delete/$id";
  Uri uri = Uri.parse(url);
  Map<String, String> headers = createHeaders();

  http.Response response = await http.delete(uri, headers: headers);

  if (isValidResponse(response)) {
    return;
  } else {
     print("Nemoguće obrisati jer postoje povezani podaci.");
  }
}
  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  Future<T> getSingleById(int id) async {
    String url = "$baseURL$endpoint/$id";

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data); 
    } else {
      throw Exception("Unknown error");
    }
  }
}