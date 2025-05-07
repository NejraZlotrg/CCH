
part of 'product.dart';


Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      (json['proizvodId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
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
      json['firmaAutodijelova'] == null
          ? null
          : FirmaAutodijelova.fromJson(
              json['firmaAutodijelova'] as Map<String, dynamic>),
      json['model'] == null
          ? null
          : Model.fromJson(json['model'] as Map<String, dynamic>),
      json['godiste'] == null
          ? null
          : Godiste.fromJson(json['godiste'] as Map<String, dynamic>),
      (json['godisteId'] as num?)?.toInt(),
      json['stateMachine'] as String?,
      json['kategorija'] == null
          ? null
          : Kategorija.fromJson(json['kategorija'] as Map<String, dynamic>),
      json['proizvodjac'] == null
          ? null
          : Proizvodjac.fromJson(json['proizvodjac'] as Map<String, dynamic>),
      (json['cijenaSaPopustomZaAutoservis'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'proizvodId': instance.proizvodId,
      'naziv': instance.naziv,
      'sifra': instance.sifra,
      'cijena': instance.cijena,
      'vidljivo': instance.vidljivo,
      'cijenaSaPopustomZaAutoservis': instance.cijenaSaPopustomZaAutoservis,
      'popust': instance.popust,
      'slika': instance.slika,
      'cijenaSaPopustom': instance.cijenaSaPopustom,
      'originalniBroj': instance.originalniBroj,
      'opis': instance.opis,
      'modelId': instance.modelId,
      'kategorijaId': instance.kategorijaId,
      'kategorija': instance.kategorija,
      'firmaAutodijelovaID': instance.firmaAutodijelovaID,
      'firmaAutodijelova': instance.firmaAutodijelova,
      'proizvodjacId': instance.proizvodjacId,
      'proizvodjac': instance.proizvodjac,
      'model': instance.model,
      'godisteId': instance.godisteId,
      'godiste': instance.godiste,
      'vozilo': instance.vozilo,
      'voziloId': instance.voziloId,
      'stateMachine': instance.stateMachine,
    };
