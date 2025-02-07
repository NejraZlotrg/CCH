// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      (json['modelId'] as num).toInt(),
      json['Vidljivo'] as bool?,
      json['nazivModela'] as String?,
      json['vozilo'] == null
          ? null
          : Vozilo.fromJson(json['vozilo'] as Map<String, dynamic>),
      (json['voziloId'] as num?)?.toInt(),
      (json['godisteId'] as num?)?.toInt(),
      json['godiste'] == null
          ? null
          : Godiste.fromJson(json['godiste'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'modelId': instance.modelId,
      'nazivModela': instance.nazivModela,
      'voziloId': instance.voziloId,
      'vozilo': instance.vozilo,
      'godisteId': instance.godisteId,
      'godiste': instance.godiste,
      'Vidljivo': instance.Vidljivo,
    };
