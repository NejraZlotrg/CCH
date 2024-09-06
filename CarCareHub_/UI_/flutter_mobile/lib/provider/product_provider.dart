import 'dart:convert';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProductProvider with ChangeNotifier {
  static String? _baseURL;
  final String _endpoint = "api/proizvodi/ProizvodiGetAll"; ///////ISPRAVITI PUTANJU/////
  
  ProductProvider() {
    _baseURL = const String.fromEnvironment("baseURL", 
                  defaultValue: "https://localhost:7209/");
  }

  Future<SearchResult<Product>> get({dynamic filter}) async {
    var url = "$_baseURL$_endpoint";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

  //  print("Status code: ${response.statusCode}");
    //print("Response body: ${response.body}");

    if(isValidResponse(response)){
      var data = jsonDecode(response.body);

      var result = new SearchResult<Product>();

      result.count = data['count'];

      for ( var item in data['result']) {
        result.result.add(Product.fromJson(item));
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
}
