import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart';

@JsonSerializable()
class Model {
  final int modelId;
  final String? nazivModela;
  final int? voziloId;
  final Vozilo? vozilo;
  final int? godisteId;
  final Godiste? godiste;
  bool? vidljivo;

  Model(this.modelId, this.vidljivo, this.nazivModela, this.vozilo,
      this.voziloId, this.godisteId, this.godiste);

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelToJson(this);
}
