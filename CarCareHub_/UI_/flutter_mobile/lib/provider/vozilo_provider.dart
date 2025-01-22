import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class VoziloProvider extends BaseProvider<Vozilo> {
  VoziloProvider(): super("/api/vozilo");

  @override
  Vozilo fromJson(data) {
    // TODO: implement fromJson
    return Vozilo.fromJson(data);
  }

}
