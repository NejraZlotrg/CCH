import 'package:flutter_mobile/models/autoservis_usluge.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class AutoservisUslugeProvider extends BaseProvider<AutoservisUsluge> {
  AutoservisUslugeProvider():super("api/AutoservisUsluge");

  @override
  AutoservisUsluge fromJson(data) {
    // TODO: implement fromJson
    return AutoservisUsluge.fromJson(data);
  }
  
  Future<List<AutoservisUsluge>> getByAutoservisId(int autoservisId) async {
    // Kreiramo filter kao mapu
    var filter = {'autoservisId': autoservisId};

    // Koristimo osnovnu get metodu sa filterom
    var searchResult = await get(filter: filter);
    
    // Vraćamo listu rezultata
    return searchResult.result;
  }
}
