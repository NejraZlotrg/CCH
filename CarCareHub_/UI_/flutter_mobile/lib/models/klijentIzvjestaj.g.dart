// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'klijentIzvjestaj.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KlijentIzvjestaj _$KlijentIzvjestajFromJson(Map<String, dynamic> json) =>
    KlijentIzvjestaj(
      klijentId: (json['klijentId'] as num).toInt(),
      imePrezime: json['imePrezime'] as String,
      ukupanIznos: (json['ukupanIznos'] as num).toDouble(),
      brojNarudzbi: (json['brojNarudzbi'] as num).toInt(),
      prosjecnaVrijednost: (json['prosjecnaVrijednost'] as num).toDouble(),
      najpopularnijiProizvodi: (json['najpopularnijiProizvodi']
              as List<dynamic>)
          .map((e) => ProizvodStatistika.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$KlijentIzvjestajToJson(KlijentIzvjestaj instance) =>
    <String, dynamic>{
      'klijentId': instance.klijentId,
      'imePrezime': instance.imePrezime,
      'ukupanIznos': instance.ukupanIznos,
      'brojNarudzbi': instance.brojNarudzbi,
      'prosjecnaVrijednost': instance.prosjecnaVrijednost,
      'najpopularnijiProizvodi': instance.najpopularnijiProizvodi,
    };
