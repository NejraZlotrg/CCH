
// ignore_for_file: file_names

part of 'chatAutoservisKlijent.dart';


chatAutoservisKlijent _$chatAutoservisKlijentFromJson(
        Map<String, dynamic> json) =>
    chatAutoservisKlijent(
      (json['id'] as num).toInt(),
      (json['klijentId'] as num).toInt(),
      (json['autoservisId'] as num).toInt(),
      json['autoservisNaziv'] as String,
      json['klijentIme'] as String,
      json['poruka'] as String?,
      json['poslanoOdKlijenta'] as bool,
      DateTime.parse(json['vrijemeSlanja'] as String),
    );

Map<String, dynamic> _$chatAutoservisKlijentToJson(
        chatAutoservisKlijent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'klijentId': instance.klijentId,
      'klijentIme': instance.klijentIme,
      'autoservisId': instance.autoservisId,
      'autoservisNaziv': instance.autoservisNaziv,
      'poruka': instance.poruka,
      'poslanoOdKlijenta': instance.poslanoOdKlijenta,
      'vrijemeSlanja': instance.vrijemeSlanja.toIso8601String(),
    };
