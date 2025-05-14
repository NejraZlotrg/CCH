import 'package:json_annotation/json_annotation.dart';

part 'proizvodjac.g.dart';

@JsonSerializable()
class Proizvodjac {
  int? proizvodjacId;
  String? nazivProizvodjaca;
  bool? vidljivo;

  Proizvodjac(this.proizvodjacId, this.vidljivo, this.nazivProizvodjaca);

  factory Proizvodjac.fromJson(Map<String, dynamic> json) =>
      _$ProizvodjacFromJson(json);

  Map<String, dynamic> toJson() => _$ProizvodjacToJson(this);
}
