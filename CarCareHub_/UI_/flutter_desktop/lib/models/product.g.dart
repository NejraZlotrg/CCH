// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      (json['proizvodId'] as num?)?.toInt(),
      json['Vidljivo'] as bool?,
      (json['voziloId'] as num?)?.toInt(),
      json['naziv'] as String?,
      json['sifra'] as String?,
      (json['cijena'] as num?)?.toDouble(),
      (json['popust'] as num?)?.toInt(),
      json['slika'] as String?,
      (json['cijenaSaPopustom'] as num?)?.toDouble(),
      json['originalniBroj'] as String?,
      json['opis'] as String?,
      (json['modelId'] as num?)?.toInt(),
      (json['kategorijaId'] as num?)?.toInt(),
      json['vozilo'] == null
          ? null
          : Vozilo.fromJson(json['vozilo'] as Map<String, dynamic>),
      (json['firmaAutodijelovaID'] as num?)?.toInt(),
      (json['proizvodjacId'] as num?)?.toInt(),
      json['firmaAutoDijelova'] == null
          ? null
          : FirmaAutodijelova.fromJson(
              json['firmaAutoDijelova'] as Map<String, dynamic>),
      json['model'] == null
          ? null
          : Model.fromJson(json['model'] as Map<String, dynamic>),
      json['modelProizvoda'] as String?,
      json['godiste'] == null
          ? null
          : Godiste.fromJson(json['godiste'] as Map<String, dynamic>),
      (json['godisteId'] as num?)?.toInt(),
      json['stateMachine'] as String?,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'proizvodId': instance.proizvodId,
      'naziv': instance.naziv,
      'sifra': instance.sifra,
      'cijena': instance.cijena,
      'Vidljivo': instance.Vidljivo,
      'popust': instance.popust,
      'slika': instance.slika,
      'cijenaSaPopustom': instance.cijenaSaPopustom,
      'originalniBroj': instance.originalniBroj,
      'modelProizvoda': instance.modelProizvoda,
      'opis': instance.opis,
      'modelId': instance.modelId,
      'kategorijaId': instance.kategorijaId,
      'firmaAutodijelovaID': instance.firmaAutodijelovaID,
      'firmaAutoDijelova': instance.firmaAutoDijelova,
      'proizvodjacId': instance.proizvodjacId,
      'model': instance.model,
      'godisteId': instance.godisteId,
      'godiste': instance.godiste,
      'vozilo': instance.vozilo,
      'voziloId': instance.voziloId,
      'stateMachine': instance.stateMachine,
    };
