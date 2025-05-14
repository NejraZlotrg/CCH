import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class KategorijaProvider extends BaseProvider<Kategorija> {
  KategorijaProvider() : super("api/kategorija");

  @override
  Kategorija fromJson(data) {
    return Kategorija.fromJson(data);
  }
}
