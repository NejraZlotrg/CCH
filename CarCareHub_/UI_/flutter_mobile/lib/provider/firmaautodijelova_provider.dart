import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class FirmaAutodijelovaProvider extends BaseProvider<FirmaAutodijelova> {
  FirmaAutodijelovaProvider():super("api/firmaAutodijelova");

  @override
  FirmaAutodijelova fromJson(data) {
    // TODO: implement fromJson
    return FirmaAutodijelova.fromJson(data);
  }

}
