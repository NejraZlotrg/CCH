// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      (json['proizvodId'] as num?)?.toInt(),
      json['naziv'] as String?,
      json['sifra'] as String?,
      (json['cijena'] as num?)?.toDouble(),
      (json['popust'] as num?)?.toInt(),
      json['slika'] as String?,
      (json['cijenaSaPopustom'] as num?)?.toDouble(),
      json['originalniBroj'] as String?,
      json['model'] as String?,
      json['opis'] as String?,
      (json['voziloId'] as num?)?.toInt(),
      (json['kategorijaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'proizvodId': instance.proizvodId,
      'naziv': instance.naziv,
      'sifra': instance.sifra,
      'cijena': instance.cijena,
      'popust': instance.popust,
      'slika': instance.slika,
      'cijenaSaPopustom': instance.cijenaSaPopustom,
      'originalniBroj': instance.originalniBroj,
      'model': instance.model,
      'opis': instance.opis,
      'voziloId': instance.voziloId,
      'kategorijaId': instance.kategorijaId,
    };
