// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korpa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korpa _$KorpaFromJson(Map<String, dynamic> json) => Korpa(
      korpaId: (json['korpaId'] as num?)?.toInt(),
      vidljivo: json['vidljivo'] as bool?,
      proizvodId: (json['proizvodId'] as num?)?.toInt(),
      klijentId: (json['klijentId'] as num?)?.toInt(),
      autoservisId: (json['autoservisId'] as num?)?.toInt(),
      zaposlenikId: (json['zaposlenikId'] as num?)?.toInt(),
      kolicina: (json['kolicina'] as num?)?.toInt(),
      ukupnaCijenaProizvoda:
          (json['ukupnaCijenaProizvoda'] as num?)?.toDouble(),
    )
      ..proizvod = json['proizvod'] == null
          ? null
          : Product.fromJson(json['proizvod'] as Map<String, dynamic>)
      ..klijent = json['klijent'] == null
          ? null
          : Klijent.fromJson(json['klijent'] as Map<String, dynamic>)
      ..autoservis = json['autoservis'] == null
          ? null
          : Autoservis.fromJson(json['autoservis'] as Map<String, dynamic>)
      ..zaposlenik = json['zaposlenik'] == null
          ? null
          : Zaposlenik.fromJson(json['zaposlenik'] as Map<String, dynamic>);

Map<String, dynamic> _$KorpaToJson(Korpa instance) => <String, dynamic>{
      'korpaId': instance.korpaId,
      'proizvodId': instance.proizvodId,
      'proizvod': instance.proizvod,
      'klijentId': instance.klijentId,
      'klijent': instance.klijent,
      'autoservisId': instance.autoservisId,
      'autoservis': instance.autoservis,
      'zaposlenikId': instance.zaposlenikId,
      'zaposlenik': instance.zaposlenik,
      'kolicina': instance.kolicina,
      'ukupnaCijenaProizvoda': instance.ukupnaCijenaProizvoda,
      'vidljivo': instance.vidljivo,
    };
