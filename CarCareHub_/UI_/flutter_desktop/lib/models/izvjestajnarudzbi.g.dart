// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'IzvjestajNarudzbi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IzvjestajNarudzbi _$IzvjestajNarudzbiFromJson(Map<String, dynamic> json) =>
    IzvjestajNarudzbi(
      (json['narudzbaId'] as num?)?.toInt(),
      json['datumNarudzbe'] == null
          ? null
          : DateTime.parse(json['datumNarudzbe'] as String),
      json['klijent'] as String?,
      json['autoservis'] as String?,
      json['zaposlenik'] as String?,
      (json['ukupnaCijena'] as num?)?.toDouble(),
      json['status'] as bool?,
    );

Map<String, dynamic> _$IzvjestajNarudzbiToJson(IzvjestajNarudzbi instance) =>
    <String, dynamic>{
      'narudzbaId': instance.narudzbaId,
      'datumNarudzbe': instance.datumNarudzbe?.toIso8601String(),
      'klijent': instance.klijent,
      'autoservis': instance.autoservis,
      'zaposlenik': instance.zaposlenik,
      'ukupnaCijena': instance.ukupnaCijena,
      'status': instance.status,
    };
