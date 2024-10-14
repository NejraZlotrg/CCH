import 'package:json_annotation/json_annotation.dart';
part 'grad.g.dart';

@JsonSerializable()
class Grad {
  int? gradId;
  String? nazivGrada;
  int? drzavaId;


  Grad(this.gradId, this.nazivGrada, this.drzavaId);

  
  factory Grad.fromJson(Map<String,dynamic> json) => _$GradFromJson(json);


  Map<String,dynamic> toJson() => _$GradToJson(this);
}