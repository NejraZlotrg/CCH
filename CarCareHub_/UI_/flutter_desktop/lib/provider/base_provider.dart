import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseURL;
  final String _endpoint;

  BaseProvider(String endpoint) : _endpoint = endpoint {
    const apiHost =
        String.fromEnvironment("API_HOST", defaultValue: "localhost");
    const apiPort = String.fromEnvironment("API_PORT", defaultValue: "5269");
    _baseURL = "http://$apiHost:$apiPort/";
  }

  String? get baseURL => _baseURL;
  String? get endpoint => _endpoint;

  String buildUrl(String path) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    String endpoint = _endpoint.endsWith('/')
        ? _endpoint.substring(0, _endpoint.length - 1)
        : _endpoint;

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

    debugPrint("GET Request: $uri");
    debugPrint("Headers: $headers");

    http.Response response = await http.get(uri, headers: headers);
    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

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
    String url = "$_baseURL$_endpoint/Admin";
    if (filter != null) {
      String queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    debugPrint("GET Admin Request: $uri");
    debugPrint("Headers: $headers");

    http.Response response = await http.get(uri, headers: headers);
    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

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

  Future<List<T>> getById(int? id) async {
    String url = "$_baseURL$_endpoint/$id";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    debugPrint("GET by ID: $uri");
    debugPrint("Headers: $headers");

    http.Response response = await http.get(uri, headers: headers);
    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

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

  Future<T> insert(dynamic request) async {
    String url = "$_baseURL$_endpoint";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    String jsonRequest = jsonEncode(request);

    debugPrint("POST to: $uri");
    debugPrint("Headers: $headers");
    debugPrint("Request Body: $jsonRequest");

    http.Response response =
        await http.post(uri, headers: headers, body: jsonRequest);

    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    String url = "$_baseURL$_endpoint/$id";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    String jsonRequest = jsonEncode(request);

    debugPrint("PUT to: $uri");
    debugPrint("Headers: $headers");
    debugPrint("Request Body: $jsonRequest");

    http.Response response =
        await http.put(uri, headers: headers, body: jsonRequest);

    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<void> delete(int id) async {
    String url = "$_baseURL$_endpoint/delete/$id";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    debugPrint("DELETE to: $uri");
    debugPrint("Headers: $headers");

    http.Response response = await http.delete(uri, headers: headers);

    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (!isValidResponse(response)) {
      throw Exception("Delete failed");
    }
  }

  Future<T> getSingleById(int id) async {
    String url = "$baseURL$endpoint/$id";
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    debugPrint("GET single item by ID: $uri");
    debugPrint("Headers: $headers");

    http.Response response = await http.get(uri, headers: headers);

    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      debugPrint("Unauthorized request");
      throw Exception("Unauthorized");
    } else {
      debugPrint("Invalid response: ${response.statusCode}");
      throw Exception("Something bad happened, please try again");
    }
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
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
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

  T fromJson(data);
}
