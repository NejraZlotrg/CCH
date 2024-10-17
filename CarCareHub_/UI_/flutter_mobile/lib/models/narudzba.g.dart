// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Narudzba _$NarudzbaFromJson(Map<String, dynamic> json) => Narudzba(
      narudzbaId: (json['narudzbaId'] as num).toInt(),
      datumNarudzbe: json['datumNarudzbe'] == null
          ? null
          : DateTime.parse(json['datumNarudzbe'] as String),
      datumIsporuke: json['datumIsporuke'] == null
          ? null
          : DateTime.parse(json['datumIsporuke'] as String),
      zavrsenaNarudzba: json['zavrsenaNarudzba'] as bool?,
      popustId: (json['popustId'] as num?)?.toInt(),
      ukupnaCijenaNarudzbe: (json['ukupnaCijenaNarudzbe'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NarudzbaToJson(Narudzba instance) => <String, dynamic>{
      'narudzbaId': instance.narudzbaId,
      'datumNarudzbe': instance.datumNarudzbe?.toIso8601String(),
      'datumIsporuke': instance.datumIsporuke?.toIso8601String(),
      'zavrsenaNarudzba': instance.zavrsenaNarudzba,
      'popustId': instance.popustId,
      'ukupnaCijenaNarudzbe': instance.ukupnaCijenaNarudzbe,
    };
