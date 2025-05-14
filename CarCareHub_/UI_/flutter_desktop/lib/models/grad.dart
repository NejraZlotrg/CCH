import 'package:flutter_mobile/models/drzave.dart';
import 'package:json_annotation/json_annotation.dart';
part 'grad.g.dart';

@JsonSerializable()
class Grad {
  int? gradId;
  String? nazivGrada;
  final int? drzavaId;
  final Drzave? drzava;
  bool? vidljivo;

  Grad(this.gradId, this.nazivGrada, this.vidljivo, this.drzavaId, this.drzava);

  factory Grad.fromJson(Map<String, dynamic> json) => _$GradFromJson(json);

  Map<String, dynamic> toJson() => _$GradToJson(this);
}
