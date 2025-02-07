import 'package:flutter_mobile/models/autoservis.dart';

import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zaposlenik.g.dart';

@JsonSerializable()
class Zaposlenik {

  int? zaposlenikId;
  String? ime;
  String? prezime;
  int? maticniBroj;
  int? brojTelefona;
  Grad? grad;
  int? gradId;
  DateTime? datumRodjenja;
  String? email;
  String? username;
  String? password;
  String? PasswordAgain;
bool? Vidljivo;

  
  String? lozinkaSalt;
  String? lozinkaHash;
  int? autoservisId;
  Autoservis? autoservis;
  int? firmaAutodijelovaId;
  FirmaAutodijelova? firmaAutodijelova;
  int? ulogaId;
  Uloge? uloga;


  String? passwordAgain;

  Zaposlenik({
    this.zaposlenikId,
    this.Vidljivo,
    this.ime,
    this.prezime,
    this.maticniBroj,
    this.brojTelefona,
    this.gradId,
    this.datumRodjenja,
    this.email,
    this.username,
    this.lozinkaSalt,
    this.lozinkaHash,
    this.password,
    this.ulogaId,
    this.autoservisId,
    this.firmaAutodijelovaId,
    this.grad,
    this.autoservis,
    this.firmaAutodijelova,
    this.uloga,
    this.passwordAgain
    
  });

  factory Zaposlenik.fromJson(Map<String, dynamic> json) =>
      _$ZaposlenikFromJson(json);

  Map<String, dynamic> toJson() => _$ZaposlenikToJson(this);
}
