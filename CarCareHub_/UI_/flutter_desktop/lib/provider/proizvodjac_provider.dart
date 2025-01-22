import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class ProizvodjacProvider extends BaseProvider<Proizvodjac> {
  ProizvodjacProvider():super("api/proizvodjac");

  @override
  Proizvodjac fromJson(data) {
    // TODO: implement fromJson
    return Proizvodjac.fromJson(data);
  }

 


}
