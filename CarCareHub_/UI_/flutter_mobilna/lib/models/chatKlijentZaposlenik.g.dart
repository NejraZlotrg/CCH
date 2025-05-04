// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatKlijentZaposlenik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

chatKlijentZaposlenik _$chatKlijentZaposlenikFromJson(
        Map<String, dynamic> json) =>
    chatKlijentZaposlenik(
      (json['id'] as num).toInt(),
      (json['klijentId'] as num).toInt(),
      (json['zaposlenikId'] as num).toInt(),
      json['zaposlenikIme'] as String,
      json['klijentIme'] as String,
      json['poruka'] as String?,
      json['poslanoOdKlijenta'] as bool,
      DateTime.parse(json['vrijemeSlanja'] as String),
    );

Map<String, dynamic> _$chatKlijentZaposlenikToJson(
        chatKlijentZaposlenik instance) =>
    <String, dynamic>{
      'id': instance.id,
      'klijentId': instance.klijentId,
      'klijentIme': instance.klijentIme,
      'zaposlenikId': instance.zaposlenikId,
      'zaposlenikIme': instance.zaposlenikIme,
      'poruka': instance.poruka,
      'poslanoOdKlijenta': instance.poslanoOdKlijenta,
      'vrijemeSlanja': instance.vrijemeSlanja.toIso8601String(),
    };
