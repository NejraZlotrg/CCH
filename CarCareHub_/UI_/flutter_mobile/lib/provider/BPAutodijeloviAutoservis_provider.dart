import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/provider/base_provider.dart';


class BPAutodijeloviAutoservisProvider extends BaseProvider<BPAutodijeloviAutoservis> {
 BPAutodijeloviAutoservisProvider(): super("/api/BPAutodijeloviAutoservis"); 


 @override
BPAutodijeloviAutoservis fromJson(data) {
  return BPAutodijeloviAutoservis.fromJson(data);
  }



}
