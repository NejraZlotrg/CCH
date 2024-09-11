import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
 ProductProvider(): super("Proizvodi");


 @override
Product fromJson(data) {
  return Product.fromJson(data);
  }
}
