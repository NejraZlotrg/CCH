import 'package:flutter_mobile/models/grad.dart';
import 'package:json_annotation/json_annotation.dart';
part 'firmaautodijelova.g.dart';

@JsonSerializable()
class FirmaAutodijelova {
  int firmaAutodijelovaID;
  String? nazivFirme;
  String? adresa;
  int? gradId;
  final Grad? grad;
  String? jib;
  String? mbs;
  String? telefon;
  String? email;
  String? password;
  String? slikaProfila;
  String? username;
  int? ulogaId;
  String? passwordAgain;
bool? vidljivo;
  



  FirmaAutodijelova(
      this.firmaAutodijelovaID,
      this.vidljivo,
      this.nazivFirme,
      this.adresa,
      this.email,
      this.gradId,
      this.jib,
      this.mbs,
      this.password,
      this.slikaProfila,
      this.telefon,
      this.ulogaId,
      this.grad,
      this.passwordAgain,
      this.username);

  factory FirmaAutodijelova.fromJson(Map<String, dynamic> json) =>
      _$FirmaAutodijelovaFromJson(json);

  Map<String, dynamic> toJson() => _$FirmaAutodijelovaToJson(this);
}
