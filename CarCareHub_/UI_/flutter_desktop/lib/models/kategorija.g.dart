
part of 'kategorija.dart';


Kategorija _$KategorijaFromJson(Map<String, dynamic> json) => Kategorija(
      (json['kategorijaId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
      json['nazivKategorije'] as String?,
    );

Map<String, dynamic> _$KategorijaToJson(Kategorija instance) =>
    <String, dynamic>{
      'kategorijaId': instance.kategorijaId,
      'nazivKategorije': instance.nazivKategorije,
      'vidljivo': instance.vidljivo,
    };
