import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class UlogeProvider extends BaseProvider<Uloge> {
  UlogeProvider() : super("api/uloge");

  @override
  Uloge fromJson(data) {
    return Uloge.fromJson(data);
  }
}
