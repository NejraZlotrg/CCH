// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usluge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usluge _$UslugeFromJson(Map<String, dynamic> json) => Usluge(
      (json['uslugeId'] as num).toInt(),
      json['Vidljivo'] as bool?,
      json['nazivUsluge'] as String?,
      json['opis'] as String?,
      (json['cijena'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UslugeToJson(Usluge instance) => <String, dynamic>{
      'uslugeId': instance.uslugeId,
      'nazivUsluge': instance.nazivUsluge,
      'opis': instance.opis,
      'cijena': instance.cijena,
      'Vidljivo': instance.Vidljivo,
    };
