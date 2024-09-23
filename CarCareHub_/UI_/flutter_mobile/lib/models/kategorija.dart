import 'package:json_annotation/json_annotation.dart';

part 'kategorija.g.dart';

@JsonSerializable()
class Kategorija {
  int? kategorijaId;
  String? nazivKategorije;

  Kategorija(this.kategorijaId, this.nazivKategorije);

  
  factory Kategorija.fromJson(Map<String,dynamic> json) => _$KategorijaFromJson(json);


  Map<String,dynamic> toJson() => _$KategorijaToJson(this);
}