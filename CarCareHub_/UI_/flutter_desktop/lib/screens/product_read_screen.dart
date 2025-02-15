import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/proizvodjac_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProductReadScreen extends StatefulWidget {
  final Product? product;
  const ProductReadScreen({super.key, this.product});

  @override
  State<ProductReadScreen> createState() => _ProductReadScreenState();
}

class _ProductReadScreenState extends State<ProductReadScreen> {
  late ProductProvider _productProvider;
  late KorpaProvider _korpaProvider;

  bool isLoading = true;
  int _quantity = 1;
  File? _imageFile;
  late ModelProvider _modelProvider;
  SearchResult<Model>? modelResult;
  late KategorijaProvider _kategorijaProvider;
  SearchResult<Kategorija>? kategorijaResult;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  SearchResult<FirmaAutodijelova>? firmaAutodijelovaResult;
  late ProizvodjacProvider _proizvodjacProvider;
  final _formKey = GlobalKey<FormBuilderState>();
  SearchResult<Proizvodjac>? proizvodjacResult;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _korpaProvider = context.read<KorpaProvider>();

    _modelProvider = context.read<ModelProvider>();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _proizvodjacProvider = context.read<ProizvodjacProvider>();

    initForm();
  }

  Future<void> initForm() async {
    modelResult = await _modelProvider.get();
    kategorijaResult = await _kategorijaProvider.get();
    firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get();
    proizvodjacResult = await _proizvodjacProvider.get();

    if (widget.product != null && widget.product!.slika != null) {
      _imageFile = await _getImageFileFromBase64(widget.product!.slika!);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<File> _getImageFileFromBase64(String base64String) async {
    final bytes = base64Decode(base64String);
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.product?.naziv ?? "Detalji proizvoda"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildProductDetails(), // Prikaz podataka
                    ],
                  ),
                ),
              ),
            ),
    );
  }

Widget _buildProductDetails() {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slika
        Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    _imageFile!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.black),
                    SizedBox(height: 10),
                    Text('Nema slike',
                        style:
                            TextStyle(color: Colors.black, fontSize: 14)),
                  ],
                ),
        ),
        const SizedBox(height: 20),
    
        // Model i opis ispod slike
        if (widget.product?.modelProizvoda != null)
          Text(
            "Model: ${widget.product!.modelProizvoda!}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        const SizedBox(height: 5),
        if (widget.product?.opis != null)
          Text(
            "Opis: ${widget.product!.opis!.length > 40 ? widget.product!.opis!.substring(0, 40) + '...' : widget.product!.opis!}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            maxLines: 3, // Ograničava broj redova
            overflow: TextOverflow
                .ellipsis, // Dodaje "..." ako tekst premašuje broj redova
            softWrap: true, // Omogućava prelazak u novi red
          ),
      ],
    ),

    const SizedBox(width: 20), // Razmak između slike i podataka

    // Podaci s desne strane
    Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20), // Dodaje horizontalni padding
      child: Column(
        children: [
          // Naziv iznad tabele
          if (widget.product?.naziv != null)
            Text(
              widget.product!.naziv!,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),

          // Tabela sa cijenom
          DataTable(
            columnSpacing: 450, // Razmak između stupaca
            horizontalMargin: 10, // Horizontalni margine
            headingRowHeight: 2,
            columns: const [
              DataColumn(label: Text('')), // Prazno zaglavlje za prvi stupac
              DataColumn(label: Text('')), // Prazno zaglavlje za drugi stupac
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text('Šifra',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(widget.product?.sifra ?? 'Nema podataka')),
              ]),
              DataRow(cells: [
                const DataCell(Text('Originalni broj',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(widget.product?.originalniBroj ?? 'Nema podataka')),
              ]),
              DataRow(cells: [
                const DataCell(Text('Kategorija',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(_getKategorijaNaziv())),
              ]),
              DataRow(cells: [
                const DataCell(Text('Proizvođač',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(_getProizvodjacNaziv())),
              ]),
              DataRow(cells: [
                const DataCell(Text('Firma',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(_getFirmaAutodijelovaNaziv())),
              ]),
              DataRow(cells: [
                const DataCell(Text('Model vozila',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(_getModelNaziv())),
              ]),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(right: 75),
            child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Poravnaj sadržaj na desno
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // Poravnaj sadržaj na desno
                    children: [
                      // Linija na vrhu
                      Container(
                        width: 220, // Širina linije
                        height: 1, // Visina linije
                        color: Colors.black, // Boja linije
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (widget.product?.popust != null &&
                          widget.product!.popust! > 0)
                        Column(
                          children: [
                            Text(
                              "${widget.product!.cijena!} KM",
                              style: const TextStyle(
                                decoration: TextDecoration
                                    .lineThrough, // Precrtana cijena
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${widget.product!.cijena! * (1 - widget.product!.popust! / 100)} KM",
                              style: const TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Boldirana cijena s popustom
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      if (widget.product?.popust == null ||
                          widget.product!.popust! <= 0)
                        Text(
                          "${widget.product!.cijena!} KM",
                          style: const TextStyle(
                            fontWeight: FontWeight
                                .bold, // Boldirana cijena bez popusta
                            fontSize: 18,
                          ),
                        ),
                      const SizedBox(
                        height: 5,
                      ),

                      // Linija na dnu
                      Container(
                        width: 220, // Širina linije
                        height: 1, // Visina linije
                        color: Colors.black, // Boja linije
                      ),
                    ],
                  ),
                ]),
          ),

          if (widget.product?.cijena != null)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_quantity >= 1) _quantity--;
                    });
                  },
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Add to cart button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (widget.product?.proizvodId != null) {
                        final int productId = widget.product!.proizvodId!;

                        // Formiraj zahtjev
                        var request = Map.from(_formKey.currentState!.value);
                        request['proizvodId'] = productId;
                        request['kolicina'] = _quantity;

                        try {
                          await _korpaProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Proizvod dodan u korpu.")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Greška: ${e.toString()}")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Proizvod nije validan.")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Dodaj u korpu"),
                ),
              ],
            ),
        ],
      ),
    ))
  ]);
}

  // Metode za dobijanje naziva povezanih entiteta
  String _getKategorijaNaziv() {
    final kategorijaId = widget.product?.kategorijaId;
    if (kategorijaId == null) return 'Nema podataka';
    final kategorija = kategorijaResult?.result.firstWhere(
      (item) => item.kategorijaId == kategorijaId,
    );
    return kategorija?.nazivKategorije ?? 'Nema podataka';
  }

  String _getProizvodjacNaziv() {
    final proizvodjacId = widget.product?.proizvodjacId;
    if (proizvodjacId == null) return 'Nema podataka';
    final proizvodjac = proizvodjacResult?.result.firstWhere(
      (item) => item.proizvodjacId == proizvodjacId,
    );
    return proizvodjac?.nazivProizvodjaca ?? 'Nema podataka';
  }

  String _getFirmaAutodijelovaNaziv() {
    final firmaId = widget.product?.firmaAutodijelovaID;
    if (firmaId == null) return 'Nema podataka';
    final firma = firmaAutodijelovaResult?.result.firstWhere(
      (item) => item.firmaAutodijelovaID == firmaId,
    );
    return firma?.nazivFirme ?? 'Nema podataka';
  }

  String _getModelNaziv() {
    final modelId = widget.product?.model?.modelId;
    if (modelId == null) return 'Nema podataka';
    final model = modelResult?.result.firstWhere(
      (item) => item.modelId == modelId,
    );
    return model?.nazivModela ?? 'Nema podataka';
  }
}
