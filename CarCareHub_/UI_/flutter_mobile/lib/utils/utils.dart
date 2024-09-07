import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Authorization {
  static String? username;
  static String? password;
}

Image imageFromBase64String(String base64Image){
  return Image.memory(base64Decode(base64Image));
}

String formatNumber(dynamic){
 var f = NumberFormat('#,##0.00'); // Postavlja format sa dve decimale
  if(dynamic == null){
    return "";
  }
  return f.format(dynamic);

}