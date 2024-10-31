import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/autoservis_usluge.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:json_annotation/json_annotation.dart';
part 'autoservis_usluge.g.dart';

@JsonSerializable()
class AutoservisUsluge {
  int autoservisUslugeId;
     final int? uslugeId;
  final Usluge? usluge;
   final int? autoservisId;
  final Autoservis? autoservis;
   


  AutoservisUsluge(this.autoservisUslugeId, this.autoservis, this.autoservisId, this.usluge, this.uslugeId);

  
  factory AutoservisUsluge.fromJson(Map<String,dynamic> json) => _$AutoservisUslugeFromJson(json);


  Map<String,dynamic> toJson() => _$AutoservisUslugeToJson(this);
}