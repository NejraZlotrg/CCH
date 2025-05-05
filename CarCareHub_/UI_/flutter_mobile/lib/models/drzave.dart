import 'package:json_annotation/json_annotation.dart';
part 'drzave.g.dart';

@JsonSerializable()
class Drzave {
  int? drzavaId;
  String? nazivDrzave;
  bool? vidljivo;

  Drzave(this.drzavaId, this.vidljivo, this.nazivDrzave);

  factory Drzave.fromJson(Map<String, dynamic> json) => _$DrzaveFromJson(json);

  Map<String, dynamic> toJson() => _$DrzaveToJson(this);
}
