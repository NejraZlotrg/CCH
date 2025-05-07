import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class UslugeProvider extends BaseProvider<Usluge> {
  UslugeProvider():super("api/usluge");

  @override
  Usluge fromJson(data) {
    return Usluge.fromJson(data);
  }

   Future<List<Usluge>> getUslugaById(int id) async {
    return await getById(id); 
  }

}
