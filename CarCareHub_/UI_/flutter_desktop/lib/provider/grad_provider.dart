import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class GradProvider extends BaseProvider<Grad> {
  GradProvider():super("api/grad");

  @override
  Grad fromJson(data) {
    return Grad.fromJson(data);
  }

}