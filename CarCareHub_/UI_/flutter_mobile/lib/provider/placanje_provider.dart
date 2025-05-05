import 'dart:convert';

import 'package:flutter_mobile/models/placanje_insert.dart';
import 'package:flutter_mobile/models/rezultat_placanja.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;

class PlacanjeProvider extends BaseProvider<PlacanjeInsert> {
  PlacanjeProvider() : super("api/placanjeAutoservisDijelovi");

  @override
  PlacanjeInsert fromJson(data) {
    return PlacanjeInsert(ukupno: 0);
  }

  Future<RezultatPlacanja> create(PlacanjeInsert request) async {
    String url = buildUrl('/plati');
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({'ukupno': request.ukupno.toInt()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RezultatPlacanja.fromJson(data);
    }

    throw Exception("Greška prilikom plaćanja: ${response.body}");
  }
}
