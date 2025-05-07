
// ignore_for_file: file_names

part of 'autoservisIzvjestaj.dart';


AutoservisIzvjestaj _$AutoservisIzvjestajFromJson(Map<String, dynamic> json) =>
    AutoservisIzvjestaj(
      autoservisId: (json['autoservisId'] as num).toInt(),
      nazivAutoservisa: json['nazivAutoservisa'] as String,
      ukupanIznos: (json['ukupanIznos'] as num).toDouble(),
      brojNarudzbi: (json['brojNarudzbi'] as num).toInt(),
      prosjecnaCijena: (json['prosjecnaCijena'] as num).toDouble(),
      najpopularnijiProizvodi: (json['najpopularnijiProizvodi']
              as List<dynamic>)
          .map((e) => ProizvodStatistika.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodOd: DateTime.parse(json['periodOd'] as String),
      periodDo: DateTime.parse(json['periodDo'] as String),
    );

Map<String, dynamic> _$AutoservisIzvjestajToJson(
        AutoservisIzvjestaj instance) =>
    <String, dynamic>{
      'autoservisId': instance.autoservisId,
      'nazivAutoservisa': instance.nazivAutoservisa,
      'ukupanIznos': instance.ukupanIznos,
      'brojNarudzbi': instance.brojNarudzbi,
      'prosjecnaCijena': instance.prosjecnaCijena,
      'najpopularnijiProizvodi': instance.najpopularnijiProizvodi,
      'periodOd': instance.periodOd.toIso8601String(),
      'periodDo': instance.periodDo.toIso8601String(),
    };
