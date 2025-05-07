import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class GodisteProvider extends BaseProvider<Godiste> {
  GodisteProvider(): super("api/godiste");

  @override
  Godiste fromJson(data) {
    return Godiste.fromJson(data);
  }

}