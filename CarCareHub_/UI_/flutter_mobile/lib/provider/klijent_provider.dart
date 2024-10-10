import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class KlijentProvider extends BaseProvider<Klijent> {
  KlijentProvider(): super("api/klijent");

  @override
  Klijent fromJson(data) {
    // TODO: implement fromJson
    return Klijent.fromJson(data);
  }

}
