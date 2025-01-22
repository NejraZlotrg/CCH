import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class NarudzbaStavkeProvider extends BaseProvider<NarudzbaStavke> {
  NarudzbaStavkeProvider():super("api/narudzbaStavka");

  @override
  NarudzbaStavke fromJson(data) {
    // TODO: implement fromJson
    return NarudzbaStavke.fromJson(data);
  }

 


}
