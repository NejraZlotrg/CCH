import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class KorpaProvider extends BaseProvider<Korpa> {
  KorpaProvider() : super("api/korpa");

  @override
  Korpa fromJson(data) {
    return Korpa.fromJson(data);
  }

  Future<bool> deleteProizvodIzKorpe(int? korpaId, int? proizvodId) async {
    String url = buildUrl("/deleteProizvodIzKorpe/$korpaId/$proizvodId");
    Uri uri = Uri.parse(url);
    Map<String, String> headers = createHeaders();

    http.Response response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateKolicina(
      int? korpaId, int? proizvodId, int novaKolicina) async {
    String url =
        buildUrl('/$korpaId/proizvod/$proizvodId?novaKolicina=$novaKolicina');
    final uri = Uri.parse(url);

    try {
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> ocistiKorpu(
      {int? klijentId, int? zaposlenikId, int? autoservisId}) async {
    Uri? uri;

    if (klijentId != null && zaposlenikId == null && autoservisId == null) {
      String url = buildUrl('/ocistiKorpu?klijentId=$klijentId');
      uri = Uri.parse(url);
    } else if (zaposlenikId != null &&
        klijentId == null &&
        autoservisId == null) {
      String url = buildUrl('/ocistiKorpu?zaposlenikId=$zaposlenikId');
      uri = Uri.parse(url);
    } else if (autoservisId != null &&
        klijentId == null &&
        zaposlenikId == null) {
      String url = buildUrl('/ocistiKorpu?autoservisId=$autoservisId');
      uri = Uri.parse(url);
    } else {
      return false;
    }

    try {
      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
