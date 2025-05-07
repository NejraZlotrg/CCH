// ignore_for_file: avoid_print

import 'dart:convert';  
import 'package:http/http.dart' as http; 
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

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
Future<bool> updateKolicina(int? korpaId, int? proizvodId, int novaKolicina) async {
  final url = Uri.parse("http://localhost:7209/api/korpa/$korpaId/proizvod/$proizvodId?novaKolicina=$novaKolicina");

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Količina uspešno ažurirana.");
        notifyListeners();  
      return true;
    } else {
      print("Greška prilikom ažuriranja količine: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Exception u updateKolicina: $e");
    return false;
  }
}
Future<bool> ocistiKorpu({int? klijentId, int? zaposlenikId, int? autoservisId}) async {
  Uri? url;

  if (klijentId != null && zaposlenikId == null && autoservisId == null) {
    url = Uri.parse("http://localhost:7209/api/korpa/ocistiKorpu?klijentId=$klijentId");
  } else if (zaposlenikId != null && klijentId == null && autoservisId == null) {
    url = Uri.parse("http://localhost:7209/api/korpa/ocistiKorpu?zaposlenikId=$zaposlenikId");
  } else if (autoservisId != null && klijentId == null && zaposlenikId == null) {
    url = Uri.parse("http://localhost:7209/api/korpa/ocistiKorpu?autoservisId=$autoservisId");
  } else {
    print("Greška: Morate proslediti tačno jedan ID.");
    return false;
  }

  try {
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Korpa uspešno očišćena.");
      return true;
    } else {
      print("Greška prilikom čišćenja korpe: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Exception u ocistiKorpu: $e");
    return false;
  }
}

}