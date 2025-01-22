import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("/api/proizvodi");

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}