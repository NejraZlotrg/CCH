import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier{
  static String? _baseURL;
  final String _endpoint = "proizvodi"; ///////ISPRAVITI PUTANJU/////
  ProductProvider(){
    _baseURL= const String.fromEnvironment("baseURL", 
                    defaultValue: "localhost/port");
  }
  Future <dynamic> get() async {
    var url = "$_baseURL$_endpoint";
    var uri = Uri.parse(url);
    http.get(uri);

    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    var data = jsonDecode(response.body);
    return data;
  }
 Map<String, String> createHeaders() {
  String username = "admin";
  String password = "admin";
  String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
  
  var headers = {
    "Content-Type": "application/json",
    "Authorization": basicAuth
  };
  return headers;
  }
}