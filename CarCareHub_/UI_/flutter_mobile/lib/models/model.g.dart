// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      (json['modelId'] as num).toInt(),
      json['nazivModela'] as String,
      Vozilo.fromJson(json['vozilo'] as Map<String, dynamic>),
      (json['voziloId'] as num).toInt(),
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'modelId': instance.modelId,
      'nazivModela': instance.nazivModela,
      'voziloId': instance.voziloId,
      'vozilo': instance.vozilo,
    };
