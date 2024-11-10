import 'package:flutter_mobile/models/grad.dart';
import 'package:json_annotation/json_annotation.dart';
part 'autoservis.g.dart';

@JsonSerializable()
class Autoservis {
  int? autoservisId;
  String? naziv;
  String? adresa;
  String? vlasnikFirme;
  String? korisnickoIme;
  int?    gradId;
  String? telefon;
  String? email;
  String? password;
  String? jib;
  String? mbs;
  String? slikaProfila;
  int? ulogaId;
  int? voziloId;
  final Grad? grad;


  Autoservis(this.autoservisId, this.naziv,this.adresa,this.vlasnikFirme, this.korisnickoIme, this.gradId, this.telefon, this.password,
  this.email, this.jib, this.mbs, this.slikaProfila, this.ulogaId, this.voziloId, this.grad);

  
  factory Autoservis.fromJson(Map<String,dynamic> json) => _$AutoservisFromJson(json);


  Map<String,dynamic> toJson() => _$AutoservisToJson(this);
}