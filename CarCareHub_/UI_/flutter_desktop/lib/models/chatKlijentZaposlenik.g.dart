// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatKlijentZaposlenik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

chatKlijentZaposlenik _$chatKlijentZaposlenikFromJson(
        Map<String, dynamic> json) =>
    chatKlijentZaposlenik(
      (json['chatKlijentZaposlenikId'] as num).toInt(),
      json['Vidljivo'] as bool?,
      (json['klijentId'] as num?)?.toInt(),
      (json['zaposlenikId'] as num?)?.toInt(),
      json['zaposlenik'] == null
          ? null
          : Zaposlenik.fromJson(json['zaposlenik'] as Map<String, dynamic>),
      json['klijent'] == null
          ? null
          : Klijent.fromJson(json['klijent'] as Map<String, dynamic>),
      json['poruka'] as String?,
      json['poslanoOdKlijenta'] as bool?,
      json['vrijemeSlanja'] == null
          ? null
          : DateTime.parse(json['vrijemeSlanja'] as String),
    );

Map<String, dynamic> _$chatKlijentZaposlenikToJson(
        chatKlijentZaposlenik instance) =>
    <String, dynamic>{
      'chatKlijentZaposlenikId': instance.chatKlijentZaposlenikId,
      'klijentId': instance.klijentId,
      'klijent': instance.klijent,
      'zaposlenik': instance.zaposlenik,
      'zaposlenikId': instance.zaposlenikId,
      'poruka': instance.poruka,
      'poslanoOdKlijenta': instance.poslanoOdKlijenta,
      'vrijemeSlanja': instance.vrijemeSlanja?.toIso8601String(),
      'Vidljivo': instance.Vidljivo,
    };
