import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class ProizvodjacProvider extends BaseProvider<Model> {
  ProizvodjacProvider():super("api/proizvodjac");

  @override
  Model fromJson(data) {
    // TODO: implement fromJson
    return Model.fromJson(data);
  }

 


}
