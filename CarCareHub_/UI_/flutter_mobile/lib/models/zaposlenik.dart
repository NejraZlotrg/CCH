import 'package:json_annotation/json_annotation.dart';

part 'zaposlenik.g.dart';

@JsonSerializable()
class Zaposlenik {
  int? zaposlenikId;
  String? ime;
  String? prezime;
  /*int? maticniBroj;
  int? brojTelefona;
  String? grad;
  int? gradId;
  DateTime? datumRodjenja;
  String? email;
  String? username;
  String? lozinkaSalt;
  String? lozinkaHash;
  String? password;
  int? ulogaId;
  String? uloga;
  int? autoservisId;
  String? autoservis;
  int? firmaAutodijelovaId;
  String? firmaAutodijelova;*/

  Zaposlenik({
    this.zaposlenikId,
    this.ime,
    this.prezime,
   /* this.maticniBroj,
    this.brojTelefona,
    this.grad,
    this.gradId,
    this.datumRodjenja,
    this.email,
    this.username,
    this.lozinkaSalt,
    this.lozinkaHash,
    this.password,
    this.ulogaId,
    this.uloga,
    this.autoservisId,
    this.autoservis,
    this.firmaAutodijelovaId,
    this.firmaAutodijelova,*/
  });

  factory Zaposlenik.fromJson(Map<String, dynamic> json) =>
      _$ZaposlenikFromJson(json);

  Map<String, dynamic> toJson() => _$ZaposlenikToJson(this);
}
