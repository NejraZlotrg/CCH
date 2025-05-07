
part of 'IzvjestajNarudzbi.dart';

IzvjestajNarudzbi _$IzvjestajNarudzbiFromJson(Map<String, dynamic> json) =>
    IzvjestajNarudzbi(
      (json['narudzbaId'] as num?)?.toInt(),
      json['datumNarudzbe'] == null
          ? null
          : DateTime.parse(json['datumNarudzbe'] as String),
      json['klijent']  == null
          ? null
          : Klijent.fromJson(json['klijent'] as Map<String, dynamic>),
      json['autoservis'] == null
          ? null
          : Autoservis.fromJson(json['autoservis'] as Map<String, dynamic>),
      json['zaposlenik']== null
          ? null
          : Zaposlenik.fromJson(json['zaposlenik'] as Map<String, dynamic>),
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
