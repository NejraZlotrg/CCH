import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/proizvodjac_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';

// ignore: must_be_immutable
class ProductReadScreen extends StatefulWidget {
  Product? product;
  ProductReadScreen({super.key, this.product});

  @override
  State<ProductReadScreen> createState() => _ProductReadsScreenState();
}

class _ProductReadsScreenState extends State<ProductReadScreen> {
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
  SearchResult<Proizvodjac>? proizvodjacResult;
  SearchResult<Product>? result;

  final validator = CreateValidator();

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
    if (context.read<UserProvider>().role == "Admin") {
      modelResult = await _modelProvider.getAdmin();
      kategorijaResult = await _kategorijaProvider.getAdmin();
      firmaAutodijelovaResult = await _firmaAutodijelovaProvider.getAdmin();
      proizvodjacResult = await _proizvodjacProvider.getAdmin();
    } else {
      modelResult = await _modelProvider.get();
      kategorijaResult = await _kategorijaProvider.get();
      firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get();
      proizvodjacResult = await _proizvodjacProvider.get();
    }
    // Check if product exists and slika is not null
    if (widget.product != null && widget.product!.slika != null) {
      // Use the null assertion operator (!) to treat slika as non-null
      _imageFile = await _getImageFileFromBase64(widget.product!.slika!);
    }

    setState(() {
      isLoading = false;
    });
  }

// Function to convert base64 image to File
  Future<File> _getImageFileFromBase64(String base64String) async {
    final bytes = base64Decode(base64String);
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SearchResult<Product> data;
      if (context.read<UserProvider>().role == "Admin") {
        data =
            await _productProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
        modelResult = await _modelProvider.getAdmin();
        kategorijaResult = await _kategorijaProvider.getAdmin();
        firmaAutodijelovaResult = await _firmaAutodijelovaProvider.getAdmin();
        proizvodjacResult = await _proizvodjacProvider.getAdmin();
      } else {
        data = await _productProvider.get(filter: {'IsAllIncluded': 'true'});
        modelResult = await _modelProvider.get();
        kategorijaResult = await _kategorijaProvider.get();
        firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get();
        proizvodjacResult = await _proizvodjacProvider.get();
      }

      setState(() {
        result = data;
        // Pronađi i ažuriraj trenutni autoservis
        widget.product = data.result.firstWhere(
          (a) => a.proizvodId == widget.product?.proizvodId,
          orElse: () => widget.product!,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju podataka: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 204, 204, 204), // Siva pozadina

      appBar: AppBar(
        title: Text(widget.product?.naziv ?? "Detalji proizvoda"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildFirmaDetails(),
                      ],
                    ),
                  ),
                ),

                // Quantity selector

                // Dugme "Uredi" na dnu, vidljivo samo adminima
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.role == "Admin") {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity, // Dugme preko cele širine
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigacija na ekran za uređivanje
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        product: widget.product!,
                                      ),
                                    ),
                                  ).then((_) async {
                                    await _fetchInitialData();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 245, 19, 3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15), // Veće dugme
                                ),
                                child: const Text(
                                  "Uredi",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildFirmaDetails() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Centriranje slike i podataka
      children: [
        // Prva trećina - Povećana slika firme centrirana
        Expanded(
          flex: 1,
          child: Center(
            child: Column(
              children: [
                // Image Container
                Container(
                  width: 300, // Povećana širina slike
                  height: 300, // Povećana visina slike
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
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 70, color: Colors.black), // Veća ikona
                            SizedBox(height: 15),
                            Text('Nema slike',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18)), // Veći tekst
                          ],
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Opis",
                        style: TextStyle(
                          fontSize: 20, // Title font size
                          fontWeight: FontWeight.bold, // Bold title
                          color: Colors.black, // Title color
                        ),
                        textAlign: TextAlign
                            .start, // Align the text to the start (left)
                      ),
                    ],
                  ),
                ),

                // Add the description text under the image
                if (widget.product?.opis != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5), // Add some spacing between the image and text
                    child: Container(
                      width: 300, // Set the width of the container
                      height: 100, // Set the height of the container
                      decoration: BoxDecoration(
                        color: Colors.white, // White background
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.vertical, // Makes the text scroll vertically
                        child: Text(
                          widget.product!.opis!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          softWrap:
                              true, // Allows the text to wrap onto a new line if needed
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),

        // Razmak između slike i podataka
        const SizedBox(width: 40), // Malo veći razmak za bolji balans

        // Druge dvije trećine - Podaci firme centrirani
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.product?.naziv != null)
                Text(
                  widget.product!.naziv!,
                  style: const TextStyle(
                      fontSize: 28, // Malo veći naslov
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),

              const SizedBox(height: 25), // Veći razmak ispod naslova

              Column(
                children: [
                  // Your DataTable
                  DataTable(
                    columnSpacing: 220, // Veći razmak između stupaca
                    horizontalMargin: 10, // Horizontalni margine
                    headingRowHeight: 0, // Sakrij zaglavlje
                    dataRowHeight: 55, // Veći razmak između redova
                    columns: const [
                      DataColumn(label: SizedBox()), // Prazan zaglavni red
                      DataColumn(label: SizedBox()),
                    ],
                    rows: [
                      _buildDataRow("Sifra", widget.product?.sifra),
                      _buildDataRow(
                          "Originalni broj", widget.product?.originalniBroj),
                      _buildDataRow(
                          "Kategorija",
                          widget.product?.kategorija?.nazivKategorije ??
                              "Nema podataka"),
                      _buildDataRow(
                          "Proizvodjac",
                          widget.product?.proizvodjac?.nazivProizvodjaca ??
                              "Nema podataka"),
                      _buildDataRow(
                          "Firma autodijelova",
                          widget.product?.firmaAutodijelova?.nazivFirme ??
                              "Nema podataka"),
                      _buildDataRow(
                          "Model",
                          widget.product?.model?.nazivModela ??
                              "Nema podataka"),
                      DataRow(cells: [
                        DataCell(SizedBox()), // Empty space for alignment
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.only(right: 75),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .end, // Poravnaj sadržaj na desno
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .end, // Poravnaj sadržaj na desno
                                  children: [
                                    Container(
                                      width: 220, // Širina linije
                                      height:
                                          0.5, // Reduced height to fit within the available space
                                      color: Colors.black, // Boja linije
                                    ),
                                    const SizedBox(height: 3), // Reduced gap
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
                                              fontSize: 14, // Reduced font size
                                            ),
                                          ),
                                          Text(
                                            "${widget.product!.cijena! * (1 - widget.product!.popust! / 100)} KM",
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Boldirana cijena s popustom
                                              color: Colors.red,
                                              fontSize: 14, // Reduced font size
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
                                          fontSize: 16, // Adjusted font size
                                        ),
                                      ),
                                    const SizedBox(height: 3), // Reduced gap
                                    Container(
                                      width: 220, // Širina linije
                                      height: 0.5, // Reduced height
                                      color: Colors.black, // Boja linije
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),

                  // Quantity selector and Add to Cart button
                  Padding(
                    padding: const EdgeInsets.only(right: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantity >= 1) _quantity--;
                            });
                          },
                        ),
                        Text('$_quantity',
                            style: const TextStyle(fontSize: 20)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (widget.product?.proizvodId != null) {
                              final int productId = widget.product!.proizvodId!;

                              // Use the quantity from the state
                              final quantity = _quantity;

                              try {
                                // Create the request map and pass the values
                                var request = {
                                  'proizvodId': productId,
                                  'kolicina': quantity,
                                };

                                await _korpaProvider.insert(request);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Proizvod dodan u korpu.")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Greška: ${e.toString()}")),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Proizvod nije validan.")),
                              );
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

// Funkcija za kreiranje jednog reda u tabeli s dodatnim razmakom
  DataRow _buildDataRow(String label, String? value) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 12), // Još veći razmak unutar ćelije
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 12), // Još veći razmak unutar ćelije
            child: Text(value ?? 'Nema podataka',
                style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
