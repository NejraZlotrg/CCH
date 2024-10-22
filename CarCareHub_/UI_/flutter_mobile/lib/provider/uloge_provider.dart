
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class UlogeProvider extends BaseProvider<Uloge> {
  UlogeProvider():super("api/uloge");

  @override
  Uloge fromJson(data) {
    // TODO: implement fromJson
    return Uloge.fromJson(data);
  }

}
