import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class KorpaProvider extends BaseProvider<Korpa> {
  KorpaProvider():super("api/korpa");

  @override
  Korpa fromJson(data) {
    // TODO: implement fromJson
    return Korpa.fromJson(data);
  }


}
