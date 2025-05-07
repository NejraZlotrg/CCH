import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class ModelProvider extends BaseProvider<Model> {
  ModelProvider():super("api/model");

  @override
  Model fromJson(data) {
    return Model.fromJson(data);
  }

 


}
