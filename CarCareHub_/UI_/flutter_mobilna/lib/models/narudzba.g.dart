// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Narudzba _$NarudzbaFromJson(Map<String, dynamic> json) => Narudzba(
      narudzbaId: (json['narudzbaId'] as num).toInt(),
      vidljivo: json['vidljivo'] as bool?,
      datumNarudzbe: json['datumNarudzbe'] == null
          ? null
          : DateTime.parse(json['datumNarudzbe'] as String),
      datumIsporuke: json['datumIsporuke'] == null
          ? null
          : DateTime.parse(json['datumIsporuke'] as String),
      zavrsenaNarudzba: json['zavrsenaNarudzba'] as bool? ?? false,
      ukupnaCijenaNarudzbe: (json['ukupnaCijenaNarudzbe'] as num?)?.toDouble(),
      adresa: json['adresa'] as String?,
    )
      ..klijentId = (json['klijentId'] as num?)?.toInt()
      ..klijent = json['klijent'] == null
          ? null
          : Klijent.fromJson(json['klijent'] as Map<String, dynamic>)
      ..autoservisId = (json['autoservisId'] as num?)?.toInt()
      ..autoservis = json['autoservis'] == null
          ? null
          : Autoservis.fromJson(json['autoservis'] as Map<String, dynamic>)
      ..zaposlenikId = (json['zaposlenikId'] as num?)?.toInt()
      ..zaposlenik = json['zaposlenik'] == null
          ? null
          : Zaposlenik.fromJson(json['zaposlenik'] as Map<String, dynamic>);

Map<String, dynamic> _$NarudzbaToJson(Narudzba instance) => <String, dynamic>{
      'narudzbaId': instance.narudzbaId,
      'datumNarudzbe': instance.datumNarudzbe?.toIso8601String(),
      'datumIsporuke': instance.datumIsporuke?.toIso8601String(),
      'zavrsenaNarudzba': instance.zavrsenaNarudzba,
      'ukupnaCijenaNarudzbe': instance.ukupnaCijenaNarudzbe,
      'vidljivo': instance.vidljivo,
      'klijentId': instance.klijentId,
      'klijent': instance.klijent,
      'autoservisId': instance.autoservisId,
      'autoservis': instance.autoservis,
      'zaposlenikId': instance.zaposlenikId,
      'zaposlenik': instance.zaposlenik,
      'adresa': instance.adresa,
    };
