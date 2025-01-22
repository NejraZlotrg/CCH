import 'package:json_annotation/json_annotation.dart';
part 'godiste.g.dart';

@JsonSerializable()
class Godiste {
  int? godisteId;
  int? godiste_;


  Godiste(this.godisteId, this.godiste_);

  
  factory Godiste.fromJson(Map<String,dynamic> json) => _$GodisteFromJson(json);


  Map<String,dynamic> toJson() => _$GodisteToJson(this);
}