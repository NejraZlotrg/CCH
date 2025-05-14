import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:json_annotation/json_annotation.dart';

part 'BPAutodijeloviAutoservis.g.dart';

@JsonSerializable()
class BPAutodijeloviAutoservis {
  int? bpAutodijeloviAutoservisId;
  FirmaAutodijelova? firmaAutodijelova;
  Autoservis? autoservis;
  int? firmaAutodijelovaId;
  bool? vidljivo;
  int? autoservisId;

  BPAutodijeloviAutoservis(
    this.bpAutodijeloviAutoservisId,
    this.vidljivo,
    this.firmaAutodijelova,
    this.firmaAutodijelovaId,
    this.autoservis,
    this.autoservisId,
  );

  factory BPAutodijeloviAutoservis.fromJson(Map<String, dynamic> json) =>
      _$BPAutodijeloviAutoservisFromJson(json);

  Map<String, dynamic> toJson() => _$BPAutodijeloviAutoservisToJson(this);
}
