// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      (json['modelId'] as num?)?.toInt(),
      json['nazivModela'] as String?,
      json['markaVozila'] as String?,
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'modelId': instance.modelId,
      'nazivModela': instance.nazivModela,
      'markaVozila': instance.markaVozila,
    };
