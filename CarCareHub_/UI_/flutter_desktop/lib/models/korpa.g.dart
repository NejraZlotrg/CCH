// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korpa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korpa _$KorpaFromJson(Map<String, dynamic> json) => Korpa(
      korpaId: (json['korpaId'] as num?)?.toInt(),
      proizvodId: (json['proizvodId'] as num?)?.toInt(),
      klijentId: (json['klijentId'] as num?)?.toInt(),
      autoservisId: (json['autoservisId'] as num?)?.toInt(),
      zaposlenikId: (json['zaposlenikId'] as num?)?.toInt(),
      kolicina: (json['kolicina'] as num?)?.toInt(),
      ukupnaCijenaProizvoda:
          (json['ukupnaCijenaProizvoda'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$KorpaToJson(Korpa instance) => <String, dynamic>{
      'korpaId': instance.korpaId,
      'proizvodId': instance.proizvodId,
      'klijentId': instance.klijentId,
      'autoservisId': instance.autoservisId,
      'zaposlenikId': instance.zaposlenikId,
      'kolicina': instance.kolicina,
      'ukupnaCijenaProizvoda': instance.ukupnaCijenaProizvoda,
    };
