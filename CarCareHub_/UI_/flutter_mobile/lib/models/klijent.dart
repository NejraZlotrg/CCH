import 'package:json_annotation/json_annotation.dart';
part 'klijent.g.dart';

@JsonSerializable()
class Klijent {
  int klijentId;
  String? ime;
  String? prezime;
  String? username;
  String? email;
  String? password;
  String? passwordAgain;
  String? lozinkaSalt;
  String? lozinkaHash;
  String? spol;
  String? brojTelefona;
  int? gradId;
  int? ulogaId;
bool? vidljivo;
String? adresa;


  Klijent(this.klijentId, this.vidljivo, this.adresa, this.ime,this.prezime,this.username,this.email,this.password,this.lozinkaSalt,this.lozinkaHash,this.spol,this.brojTelefona,this.gradId,this.passwordAgain);

  
  factory Klijent.fromJson(Map<String,dynamic> json) => _$KlijentFromJson(json);


  Map<String,dynamic> toJson() => _$KlijentToJson(this);
}