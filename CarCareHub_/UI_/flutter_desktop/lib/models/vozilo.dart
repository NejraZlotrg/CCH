import 'package:json_annotation/json_annotation.dart';
part 'vozilo.g.dart';

@JsonSerializable()
class Vozilo {
  int? voziloId;
  String? markaVozila;

  Vozilo(this.voziloId, this.markaVozila);

  
  factory Vozilo.fromJson(Map<String,dynamic> json) => _$VoziloFromJson(json);


  Map<String,dynamic> toJson() => _$VoziloToJson(this);
}