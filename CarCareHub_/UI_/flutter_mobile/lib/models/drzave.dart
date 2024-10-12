import 'package:json_annotation/json_annotation.dart';
part 'drzave.g.dart';

@JsonSerializable()
class Drzave {
  int? drzavaId;
  String? nazivDrzave;


  Drzave(this.drzavaId, this.nazivDrzave);

  
  factory Drzave.fromJson(Map<String,dynamic> json) => _$DrzaveFromJson(json);


  Map<String,dynamic> toJson() => _$DrzaveToJson(this);
}