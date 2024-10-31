import 'package:flutter_mobile/models/autoservis_usluge.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class AutoservisUslugeProvider extends BaseProvider<AutoservisUsluge> {
  AutoservisUslugeProvider():super("api/AutoservisUsluge");

  @override
  AutoservisUsluge fromJson(data) {
    // TODO: implement fromJson
    return AutoservisUsluge.fromJson(data);
  }

}
