import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class ZaposlenikProvider extends BaseProvider<Zaposlenik> {
  ZaposlenikProvider():super("api/zaposlenici");

  @override
  Zaposlenik fromJson(data) {
    // TODO: implement fromJson
    return Zaposlenik.fromJson(data);
  }

}
