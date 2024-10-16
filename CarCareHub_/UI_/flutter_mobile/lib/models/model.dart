import 'package:flutter_mobile/models/vozilo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart'; 

@JsonSerializable()
class Model {
   final int modelId;
  final String nazivModela;
  final int voziloId;
  final Vozilo vozilo;
  


  Model(this.modelId, this.nazivModela, this.vozilo, this.voziloId);

  
  factory Model.fromJson(Map<String,dynamic> json) => _$ModelFromJson(json);


  Map<String,dynamic> toJson() => _$ModelToJson(this);
}