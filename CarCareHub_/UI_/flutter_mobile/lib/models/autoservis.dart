import 'package:flutter_mobile/models/grad.dart';
import 'package:json_annotation/json_annotation.dart';

part 'autoservis.g.dart';

@JsonSerializable()
class Autoservis {
  int? autoservisId;
  String? naziv;
  String? adresa;
  String? vlasnikFirme;
  int?    gradId;
  String? telefon;
  String? email;
  String? username;
  String? password;
  String? passwordAgain;
  String? jib;
  String? mbs;
  String? slikaProfila;
  String? slikaThumb;
bool? vidljivo;
  
  int? ulogaId;
  int? zaposlenikId;

  int? voziloId;
  final Grad? grad;


  Autoservis(this.autoservisId, this.vidljivo, this.naziv,this.adresa,this.vlasnikFirme, this.gradId,this.slikaThumb, this.telefon, this.password,
  this.email, this.jib, this.mbs, this.slikaProfila, this.ulogaId, this.voziloId, this.grad,this.passwordAgain,this.username);

  
  factory Autoservis.fromJson(Map<String,dynamic> json) => _$AutoservisFromJson(json);


  Map<String,dynamic> toJson() => _$AutoservisToJson(this);
}



