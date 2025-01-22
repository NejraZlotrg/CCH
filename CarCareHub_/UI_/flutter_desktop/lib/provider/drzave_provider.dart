import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class DrzaveProvider extends BaseProvider<Drzave> {
  DrzaveProvider():super("api/drzava");

  @override
  Drzave fromJson(data) {
    // TODO: implement fromJson
    return Drzave.fromJson(data);
  }

}
