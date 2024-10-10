import 'package:json_annotation/json_annotation.dart';
part 'klijent.g.dart';

@JsonSerializable()
class Klijent {
  int? KlijentId;
  String? Ime;
  String? Prezime;
  String? Username;
  String? Email;
  String? Password;
  String? LozinkaSalt;
  String? LozinkaHash;
  String? Spol;
  String? BrojTelefona;
  int? GradId;


  Klijent(this.KlijentId, this.Ime,this.Prezime,this.Username,this.Email,this.Password,this.LozinkaSalt,this.LozinkaHash,this.Spol,this.BrojTelefona,this.GradId);

  
  factory Klijent.fromJson(Map<String,dynamic> json) => _$KlijentFromJson(json);


  Map<String,dynamic> toJson() => _$KlijentToJson(this);
}