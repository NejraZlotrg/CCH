import 'dart:convert';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseURL;
  String _endpoint = ""; ///////ISPRAVITI PUTANJU/////
  
  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseURL = const String.fromEnvironment("baseURL", 
                  defaultValue: "https://localhost:7209/");
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseURL$_endpoint";

  if(filter != null){
    var queryString = getQueryString(filter);
    url =  "$url?$queryString";
  }
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

  //  print("Status code: ${response.statusCode}");
    //print("Response body: ${response.body}");

    if(isValidResponse(response)){
      var data = jsonDecode(response.body);

      var result = new SearchResult<T>();

      result.count = data['count'];

      for ( var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
              throw new Exception("Unknown error");
    }
  }
  /*  if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        return data;
      } catch (e) {
        print("Error decoding JSON: $e");
        return null;
      }
    } else {
      print("Request failed with status: ${response.statusCode}");
     // print("Response body: ${response.body}");
      return null;
    }
  }*/
  bool isValidResponse (Response response){
      if(response.statusCode <299){
        return true;
      } else if (response.statusCode == 401) {
        throw new Exception("Unauthorized");
      } else {
        print(response.body);
        throw new Exception("Something bad happened please try again");
      }
    }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ??"";
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    print("passed creds: $username, $password");

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };
    return headers;
  }

  String getQueryString(Map params, 
    {String prefix: '&', bool inRecursion: false}) {
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
      query += '$prefix$key=${(value as DateTime).toIso8601String()}';
    } else if (value is List || value is Map) {
      if (value is List) value = value.asMap();
      value.forEach((k, v) {
        query += getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
      });
    }
  });
  return query;
}
T fromJson(data){
  throw Exception("Method not implemented");
}
}
