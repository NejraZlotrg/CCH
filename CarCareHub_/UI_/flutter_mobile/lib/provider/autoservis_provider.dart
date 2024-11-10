import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class AutoservisProvider extends BaseProvider<Autoservis> {
 AutoservisProvider(): super("api/Autoservis"); //izmjena 16.9


 @override
Autoservis fromJson(data) {
  return Autoservis.fromJson(data);
  }



}
