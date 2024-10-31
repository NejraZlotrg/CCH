// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autoservis_usluge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutoservisUsluge _$AutoservisUslugeFromJson(Map<String, dynamic> json) =>
    AutoservisUsluge(
      (json['autoservisUslugeId'] as num).toInt(),
      json['autoservis'] == null
          ? null
          : Autoservis.fromJson(json['autoservis'] as Map<String, dynamic>),
      (json['autoservisId'] as num?)?.toInt(),
      json['usluge'] == null
          ? null
          : Usluge.fromJson(json['usluge'] as Map<String, dynamic>),
      (json['uslugeId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AutoservisUslugeToJson(AutoservisUsluge instance) =>
    <String, dynamic>{
      'autoservisUslugeId': instance.autoservisUslugeId,
      'uslugeId': instance.uslugeId,
      'usluge': instance.usluge,
      'autoservisId': instance.autoservisId,
      'autoservis': instance.autoservis,
    };
