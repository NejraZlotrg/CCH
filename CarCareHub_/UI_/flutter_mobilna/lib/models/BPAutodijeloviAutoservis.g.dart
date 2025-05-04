// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BPAutodijeloviAutoservis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BPAutodijeloviAutoservis _$BPAutodijeloviAutoservisFromJson(
        Map<String, dynamic> json) =>
    BPAutodijeloviAutoservis(
      (json['bpAutodijeloviAutoservisId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
      json['firmaAutodijelova'] == null
          ? null
          : FirmaAutodijelova.fromJson(
              json['firmaAutodijelova'] as Map<String, dynamic>),
      (json['firmaAutodijelovaId'] as num?)?.toInt(),
      json['autoservis'] == null
          ? null
          : Autoservis.fromJson(json['autoservis'] as Map<String, dynamic>),
      (json['autoservisId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BPAutodijeloviAutoservisToJson(
        BPAutodijeloviAutoservis instance) =>
    <String, dynamic>{
      'bpAutodijeloviAutoservisId': instance.bpAutodijeloviAutoservisId,
      'firmaAutodijelova': instance.firmaAutodijelova,
      'autoservis': instance.autoservis,
      'firmaAutodijelovaId': instance.firmaAutodijelovaId,
      'vidljivo': instance.vidljivo,
      'autoservisId': instance.autoservisId,
    };
