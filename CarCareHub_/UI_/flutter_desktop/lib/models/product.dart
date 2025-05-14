import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

@JsonSerializable()
class Product {
  int? proizvodId;
  String? naziv;
  String? sifra;
  double? cijena;
  bool? vidljivo;
  double? cijenaSaPopustomZaAutoservis;
  int? popust;
  String? slika;
  double? cijenaSaPopustom;
  String? originalniBroj;
  String? opis;
  int? modelId;
  int? kategorijaId;
  final Kategorija? kategorija;
  int? firmaAutodijelovaID;
  final FirmaAutodijelova? firmaAutodijelova;
  int? proizvodjacId;
  final Proizvodjac? proizvodjac;
  final Model? model;
  int? godisteId;
  final Godiste? godiste;
  final Vozilo? vozilo;
  int? voziloId;
  String? stateMachine;

  Product(
      this.proizvodId,
      this.vidljivo,
      this.voziloId,
      this.naziv,
      this.sifra,
      this.cijena,
      this.popust,
      this.slika,
      this.cijenaSaPopustom,
      this.originalniBroj,
      this.opis,
      this.modelId,
      this.kategorijaId,
      this.vozilo,
      this.firmaAutodijelovaID,
      this.proizvodjacId,
      this.firmaAutodijelova,
      this.model,
      this.godiste,
      this.godisteId,
      this.stateMachine,
      this.kategorija,
      this.proizvodjac,
      this.cijenaSaPopustomZaAutoservis);

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
