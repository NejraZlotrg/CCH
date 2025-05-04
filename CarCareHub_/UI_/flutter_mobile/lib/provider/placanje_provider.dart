import 'dart:convert';

import 'package:flutter_mobile/models/placanje_insert.dart';
import 'package:flutter_mobile/models/rezultat_placanja.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class PlacanjeProvider extends BaseProvider<PlacanjeInsert> {
  PlacanjeProvider():super("api/placanjeAutoservisDijelovi");

  @override
  PlacanjeInsert fromJson(data) {
    return PlacanjeInsert(ukupno: 0); // Napraviti .g fajl onaj
  }

Future<RezultatPlacanja> create(PlacanjeInsert request) async {
  final response = await http.post(
    Uri.parse('http://192.168.0.118:7209/api/placanjeAutoservisDijelovi/plati'),
    headers: createHeaders(),
    body: jsonEncode({
      'ukupno': request.ukupno.toInt()
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return RezultatPlacanja.fromJson(data); // Ispravno mapiranje u model
  } 

  throw Exception("Greška prilikom plaćanja: ${response.body}");
}


}
