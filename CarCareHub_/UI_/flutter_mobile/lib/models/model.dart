import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart'; 

@JsonSerializable()
class Model {
  int? modelId;
  String? nazivModela;
  int? voziloId;
  String? markaVozila;
  


  Model(this.modelId, this.nazivModela, this.markaVozila);

  
  factory Model.fromJson(Map<String,dynamic> json) => _$ModelFromJson(json);


  Map<String,dynamic> toJson() => _$ModelToJson(this);
}