import 'dart:convert';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class ZaposlenikProvider extends BaseProvider<Zaposlenik> {
  ZaposlenikProvider() : super("api/zaposlenici");

  @override
  Zaposlenik fromJson(data) {
    return Zaposlenik.fromJson(data);
  }

  Future<List<Zaposlenik>> getzaposlenikById(int id) async {
    return await getById(id); // Pozivanje funkcije getById iz osnovnog provider-a
  }

  Future<int?> getIdByUsernameAndPassword(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(buildUrl("get-id?username=$username&password=$password")), // Korišćenje buildUrl
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
        Uri.parse(buildUrl("get-vidljivo?username=$username&password=$password")), // Korišćenje buildUrl
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
      print('Error fetching vidljivo: $e');
      return null;
    }
  }

  @override
  Future<Zaposlenik> getSingleById(int id) async {
    String url = buildUrl("ZaposleniciGetByID/$id"); // Korišćenje buildUrl sa ID-jem

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();
    http.Response response = await http.get(uri, headers: headers);
    print("API odgovor: ${response.body}");

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
        Uri.parse(buildUrl("check-username/$username")), // Korišćenje buildUrl
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
