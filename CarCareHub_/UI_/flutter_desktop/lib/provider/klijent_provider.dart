// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;


class KlijentProvider extends BaseProvider<Klijent> {
  KlijentProvider(): super("api/klijent");

  @override
  Klijent fromJson(data) {
    return Klijent.fromJson(data);
  }
 Future<List<Klijent>> getKorpaById(int id) async {
    return await getById(id); 
  }
  Future<int?> getIdByUsernameAndPassword(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:7209/api/klijent/get-id?username=$username&password=$password'),  
      headers: {
        "Content-Type": "application/json",  
      },
      body: jsonEncode({
        "username": username,
        "password": password,  
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];  
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching ID: $e');
    return null;
  }
}


  Future<bool?> getVidljivoByUsernameAndPassword(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:7209/api/klijent/get-vidljivo?username=$username&password=$password'),  
      headers: {
        "Content-Type": "application/json",  
      },
      body: jsonEncode({
        "username": username,
        "password": password,  
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['vidljivo'];  
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching ID: $e');
    return null;
  }
}

  @override
  Future<Klijent> getSingleById(int id) async {
    String url = "http://localhost:7209/api/klijent/KlijentiGetByID/$id"; 

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
  
Future<bool> checkUsernameExists(String username) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:7209/api/klijent/check-username/$username'),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] as bool;
    } else {
      return false;
    }
  } catch (e) {
    print('Error checking username: $e');
    return false;
  }
}
}