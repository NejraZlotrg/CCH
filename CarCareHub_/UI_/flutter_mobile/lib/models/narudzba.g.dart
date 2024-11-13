// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Narudzba _$NarudzbaFromJson(Map<String, dynamic> json) => Narudzba(
      id: (json['id'] as num).toInt(),
      ukupnaCijenaNarudzbe: (json['ukupnaCijenaNarudzbe'] as num).toDouble(),
      datumIsporuke: DateTime.parse(json['datumIsporuke'] as String),
      zavrsenaNarudzba: json['zavrsenaNarudzba'] as bool,
    );

Map<String, dynamic> _$NarudzbaToJson(Narudzba instance) => <String, dynamic>{
      'id': instance.id,
      'ukupnaCijenaNarudzbe': instance.ukupnaCijenaNarudzbe,
      'datumIsporuke': instance.datumIsporuke.toIso8601String(),
      'zavrsenaNarudzba': instance.zavrsenaNarudzba,
    };
