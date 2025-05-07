
part of 'zaposlenikIzvjestaj.dart';


ZaposlenikIzvjestaj _$ZaposlenikIzvjestajFromJson(Map<String, dynamic> json) =>
    ZaposlenikIzvjestaj(
      zaposlenikId: (json['zaposlenikId'] as num).toInt(),
      imePrezime: json['imePrezime'] as String,
      ukupanIznos: (json['ukupanIznos'] as num).toDouble(),
      brojNarudzbi: (json['brojNarudzbi'] as num).toInt(),
      prosjecnaVrijednost: (json['prosjecnaVrijednost'] as num).toDouble(),
      najpopularnijiProizvodi: (json['najpopularnijiProizvodi']
              as List<dynamic>)
          .map((e) => ProizvodStatistika.fromJson(e as Map<String, dynamic>))
          .toList(),
      autoservis: json['autoservis'] as String,
    );

Map<String, dynamic> _$ZaposlenikIzvjestajToJson(
        ZaposlenikIzvjestaj instance) =>
    <String, dynamic>{
      'zaposlenikId': instance.zaposlenikId,
      'imePrezime': instance.imePrezime,
      'ukupanIznos': instance.ukupanIznos,
      'brojNarudzbi': instance.brojNarudzbi,
      'prosjecnaVrijednost': instance.prosjecnaVrijednost,
      'najpopularnijiProizvodi': instance.najpopularnijiProizvodi,
      'autoservis': instance.autoservis,
    };
