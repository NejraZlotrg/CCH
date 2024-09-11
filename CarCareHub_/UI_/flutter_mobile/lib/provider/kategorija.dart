import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class KategorijaProvider extends BaseProvider<Kategorija> {
  KategorijaProvider():super("Kategorija");

  @override
  Kategorija fromJson(data) {
    // TODO: implement fromJson
    return Kategorija.fromJson(data);
  }

}
