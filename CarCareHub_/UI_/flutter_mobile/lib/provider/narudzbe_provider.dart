import 'dart:convert';
import 'package:flutter_mobile/models/IzvjestajNarudzbi.dart';
import 'package:flutter_mobile/models/autoservisIzvjestaj.dart';
import 'package:flutter_mobile/models/klijentIzvjestaj.dart';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/zaposlenikIzvjestaj.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("api/narudzba");

  @override
  Narudzba fromJson(data) {
    return Narudzba.fromJson(data);
  }

  Future<Narudzba> potvrdiNarudzbu(int narudzbaId) async {
    String url = buildUrl("/$narudzbaId/potvrdi");
    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.put(uri, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Narudzba narudzba = Narudzba.fromJson(data);
        return narudzba;
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }

  Future<SearchResult<Narudzba>> getNarudzbePoUseru(int id) async {
    String url = buildUrl("/$id/GetPoUseru");
    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SearchResult<Narudzba> narudzbe = SearchResult<Narudzba>();
        for (var item in data) {
          narudzbe.result.add(fromJson(item));
        }
        return narudzbe;
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }

  Future<List<IzvjestajNarudzbi>> getIzvjestaj({
    DateTime? odDatuma,
    DateTime? doDatuma,
    int? kupacId,
    int? zaposlenikId,
    int? autoservisId,
  }) async {
    String url = buildUrl("/izvjestaj");

    Map<String, String> queryParams = {};
    if (odDatuma != null) {
      queryParams["odDatuma"] = odDatuma.toUtc().toIso8601String();
    }
    if (doDatuma != null) {
      queryParams["doDatuma"] = doDatuma.toUtc().toIso8601String();
    }
    if (kupacId != null) queryParams["kupacId"] = kupacId.toString();
    if (zaposlenikId != null) {
      queryParams["zaposlenikId"] = zaposlenikId.toString();
    }
    if (autoservisId != null) {
      queryParams["autoservisId"] = autoservisId.toString();
    }

    if (queryParams.isNotEmpty) {
      url += "?${Uri(queryParameters: queryParams).query}";
    }

    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => IzvjestajNarudzbi.fromJson(item)).toList();
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }

  Future<SearchResult<Narudzba>> getNarudzbeZaFirmu(int id) async {
    String url = buildUrl("/fm?id=$id");

    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        SearchResult<Narudzba> result = SearchResult<Narudzba>();

        if (data is List) {
          for (var item in data) {
            result.result.add(fromJson(item));
          }
        } else if (data is Map<String, dynamic>) {
          result.count = data['count'] ?? 0;
          if (data['result'] is List) {
            for (var item in data['result']) {
              result.result.add(fromJson(item));
            }
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

  Future<List<AutoservisIzvjestaj>> getAutoservisIzvjestaj() async {
    String url = buildUrl("/IzvjestajzaAutoservis");
    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => AutoservisIzvjestaj.fromJson(item)).toList();
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }

  Future<List<ZaposlenikIzvjestaj>> getZaposlenikIzvjestaj() async {
    String url = buildUrl("/IzvjestajzaZaposlenike");
    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => ZaposlenikIzvjestaj.fromJson(item)).toList();
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }

  Future<List<KlijentIzvjestaj>> getKlijentIzvjestaj() async {
    String url = buildUrl("/IzvjestajzaKlijenta");
    Uri uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    try {
      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => KlijentIzvjestaj.fromJson(item)).toList();
      } else {
        throw Exception('Greška: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Greška pri slanju zahtjeva: $error');
    }
  }
}
