
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

@JsonSerializable()
class Product {
  int? proizvodId;
  String? naziv;
  String? sifra;
  double? cijena;
  int? popust;
  String? slika;
  double? cijenaSaPopustom;
  String? originalniBroj;
  String? model;
  String? opis;
  int? voziloId;
  int? kategorijaId;
  int? firmaAutodijelovaID;
  final FirmaAutodijelova? firmaAutoDijelova;
  int? proizvodjacId;
  final Vozilo? vozilo;
  //final Model? _model;
  //final Godiste? godiste;

  Product(this.proizvodId,this.naziv,this.sifra,this.cijena,this.popust,this.slika,this.cijenaSaPopustom,this.originalniBroj,this.model,this.opis,this.voziloId,
  this.kategorijaId,this.firmaAutodijelovaID,this.proizvodjacId,this.firmaAutoDijelova,this.vozilo,/*this._model*/);

  factory Product.fromJson(Map<String,dynamic> json) => _$ProductFromJson(json);


  Map<String,dynamic> toJson() => _$ProductToJson(this);
}
