// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drzave.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Drzave _$DrzaveFromJson(Map<String, dynamic> json) => Drzave(
      (json['drzavaId'] as num?)?.toInt(),
      json['Vidljivo'] as bool?,
      json['nazivDrzave'] as String?,
    );

Map<String, dynamic> _$DrzaveToJson(Drzave instance) => <String, dynamic>{
      'drzavaId': instance.drzavaId,
      'nazivDrzave': instance.nazivDrzave,
      'Vidljivo': instance.Vidljivo,
    };
