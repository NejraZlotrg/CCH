// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategorija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kategorija _$KategorijaFromJson(Map<String, dynamic> json) => Kategorija(
      (json['kategorijaId'] as num?)?.toInt(),
      json['Vidljivo'] as bool?,
      json['nazivKategorije'] as String?,
    );

Map<String, dynamic> _$KategorijaToJson(Kategorija instance) =>
    <String, dynamic>{
      'kategorijaId': instance.kategorijaId,
      'nazivKategorije': instance.nazivKategorije,
      'Vidljivo': instance.Vidljivo,
    };
