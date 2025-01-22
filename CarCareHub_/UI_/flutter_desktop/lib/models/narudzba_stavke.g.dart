// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba_stavke.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NarudzbaStavke _$NarudzbaStavkeFromJson(Map<String, dynamic> json) =>
    NarudzbaStavke(
      (json['proizvodId'] as num?)?.toInt(),
      (json['kolicina'] as num?)?.toInt(),
      (json['ukupnaCijenaProizvoda'] as num?)?.toDouble(),
      json['proizvod'] == null
          ? null
          : Product.fromJson(json['proizvod'] as Map<String, dynamic>),
      json['narudzba'] == null
          ? null
          : Narudzba.fromJson(json['narudzba'] as Map<String, dynamic>),
      (json['narudzbaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NarudzbaStavkeToJson(NarudzbaStavke instance) =>
    <String, dynamic>{
      'proizvodId': instance.proizvodId,
      'kolicina': instance.kolicina,
      'ukupnaCijenaProizvoda': instance.ukupnaCijenaProizvoda,
      'proizvod': instance.proizvod,
      'narudzba': instance.narudzba,
      'narudzbaId': instance.narudzbaId,
    };
