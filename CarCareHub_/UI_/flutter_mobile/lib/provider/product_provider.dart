import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
 ProductProvider(): super("api/proizvodi/ProizvodiGetAll"); //izmjena 16.9


 @override
Product fromJson(data) {
  return Product.fromJson(data);
  }
}
