import 'dart:convert';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class AutoservisProvider extends BaseProvider<Autoservis> {
  AutoservisProvider() : super("api/Autoservis"); 

  @override
  Autoservis fromJson(data) {
    return Autoservis.fromJson(data);
  }

  Future<List<Autoservis>> getAutoservisById(int id) async {
    return await getById(id); 
  }

  Future<int?> getIdByUsernameAndPassword(
      String username, String password) async {
    try {
      String url = buildUrl("get-id?username=$username&password=$password");

      final response = await http.post(
        Uri.parse(url), 
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
      return null;
    }
  }

  @override
  Future<Autoservis> getSingleById(int id) async {
    String url = buildUrl('/AutoservisGetByID/$id'); 

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
      String url = buildUrl('/autoservis/check-username/$username');

      final response = await http.get(
        Uri.parse(url),
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
      return false;
    }
  }

  Future<bool?> getVidljivoByUsernameAndPassword(
      String username, String password) async {
    try {
      String url =
          buildUrl('get-vidljivo?username=$username&password=$password');

      final response = await http.post(
        Uri.parse(url), 
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
      return null;
    }
  }
}
