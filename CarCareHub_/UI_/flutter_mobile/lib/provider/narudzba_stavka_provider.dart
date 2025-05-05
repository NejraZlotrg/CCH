import 'dart:convert';

import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class NarudzbaStavkeProvider extends BaseProvider<NarudzbaStavke> {
  NarudzbaStavkeProvider() : super("api/narudzbaStavka");

  @override
  NarudzbaStavke fromJson(data) {
    return NarudzbaStavke.fromJson(data);
  }

  Future<SearchResult<NarudzbaStavke>> getStavkeZaNarudzbu(
      int narudzbaId) async {
    String url = buildUrl("/$narudzbaId/ByNarudzbaId");

    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        SearchResult<NarudzbaStavke> result = SearchResult<NarudzbaStavke>();

        result.count = data["count"] ?? 0;
        if (data["result"] is List) {
          for (var item in data["result"]) {
            result.result.add(NarudzbaStavke.fromJson(item));
          }
        }
        return result;
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }
}
