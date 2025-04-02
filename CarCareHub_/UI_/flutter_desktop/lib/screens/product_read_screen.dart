import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/kategorija_provider.dart';
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
  late ModelProvider _modelProvider;
  SearchResult<Model>? modelResult;
  late KategorijaProvider _kategorijaProvider;
  SearchResult<Kategorija>? kategorijaResult;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  SearchResult<FirmaAutodijelova>? firmaAutodijelovaResult;
  late ProizvodjacProvider _proizvodjacProvider;
  SearchResult<Proizvodjac>? proizvodjacResult;
  SearchResult<Product>? result;

  List<Product> recommendedProducts = [];
  bool isRecommendationsLoading = false;

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
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (widget.product?.proizvodId == null) return;
    
    setState(() {
      isRecommendationsLoading = true;
    });

    try {
      var products = await _productProvider.getRecommendations(widget.product!.proizvodId!);
      setState(() {
        recommendedProducts = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri učitavanju preporuka: $e")),
      );
    } finally {
      setState(() {
        isRecommendationsLoading = false;
      });
    }
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

    setState(() {
      isLoading = false;
    });
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
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
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
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.role == "Admin" || 
                        (userProvider.role == "Firma autodijelova" && 
                         userProvider.userId == widget.product?.firmaAutodijelovaID)) {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
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
                                  backgroundColor: const Color.fromARGB(255, 245, 19, 3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: const Text(
                                  "Uredi",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  if (widget.product?.stateMachine == "active") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Proizvod mora biti sakriven."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Potvrdite brisanje"),
                                      content: const Text("Da li ste sigurni da želite izbrisati ovaj proizvod?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Otkaži"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text("Izbriši"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmDelete == true) {
                                    try {
                                      await Provider.of<ProductProvider>(context, listen: false)
                                          .deleteDraftProduct(widget.product!.proizvodId!);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Proizvod je uspješno izbrisan."),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Greška pri brisanju proizvoda: $e"),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                icon: const Icon(Icons.delete),
                                label: const Text(
                                  "Izbriši proizvod",
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
    return Column(
      children: [
        Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.product!.slika != null
                          ? Image.memory(
                              base64Decode(widget.product!.slika!),
                              fit: BoxFit.contain,
                              width: double.infinity,
                            )
                          : const Center(child: Text("Nema slike")),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Opis",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  if (widget.product?.opis != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 300,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            widget.product!.opis!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
            const SizedBox(width: 40),
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  const SizedBox(height: 25),
                  Column(
                    children: [
                      DataTable(
                        columnSpacing: 220,
                        horizontalMargin: 10,
                        headingRowHeight: 0,
                        dataRowHeight: 55,
                        columns: const [
                          DataColumn(label: SizedBox()),
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
                            const DataCell(SizedBox()),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.only(right: 75),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 220,
                                          height: 0.5,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 3),
                                        if (widget.product?.popust != null &&
                                            widget.product!.popust! > 0)
                                          Column(
                                            children: [
                                              Text(
                                                "${widget.product!.cijena!} KM",
                                                style: const TextStyle(
                                                  decoration: TextDecoration.lineThrough,
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                "${widget.product!.cijena! * (1 - widget.product!.popust! / 100)} KM",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (widget.product?.popust == null ||
                                            widget.product!.popust! <= 0)
                                          Text(
                                            "${widget.product!.cijena!} KM",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        const SizedBox(height: 3),
                                        Container(
                                          width: 220,
                                          height: 0.5,
                                          color: Colors.black,
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
                      const SizedBox(height: 20,),
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
                                  final quantity = _quantity;

                                  try {
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
        ),
        
        // Preporučeni proizvodi sekcija
     const SizedBox(height: 40),
Container(
  color: const Color.fromARGB(41, 143, 143, 143),  // Red background for the whole section
  padding: const EdgeInsets.all(12),  // Optional padding
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Center(  // Centering the title
        child: Text(
          "Preporučeni proizvodi",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      const SizedBox(height: 10),
      
      if (isRecommendationsLoading)
        const Center(child: CircularProgressIndicator())
      else if (recommendedProducts.isEmpty)
        const Center(  // Centering the empty message
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Nema preporučenih proizvoda"),
          ),
        )
      else
        SizedBox(
          height: 250,
          child: Center(  // Centering the ListView
            child: ListView.separated(  // Using ListView.separated for spacing
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: recommendedProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(recommendedProducts[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 50),  // Space between cards
              padding: const EdgeInsets.only(bottom: 16),  // Padding on sides
            ),
          ),
        ),
    ],
  ),
)

      ],
    );
  }

Widget _buildProductCard(Product product) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductReadScreen(product: product),
        ),
      );
    },
    child: Container(
      width: 200, // Povećana širina
      margin: const EdgeInsets.all(12), // Veći razmak između kartica
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Veći zaobljeni uglovi
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 3,
            blurRadius: 6,
            offset: const Offset(0, 4), // Povećana sjena
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slika proizvoda
          Container(
            height: 120, // Povećana visina slike
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: product.slika != null
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(product.slika!)),
                      fit: BoxFit.cover, // Bolje pokrivanje
                    )
                  : null,
            ),
            child: product.slika == null
                ? const Center(child: Icon(Icons.image, size: 60)) // Veća ikona
                : null,
          ),
          
          // Informacije o proizvodu
          Padding(
            padding: const EdgeInsets.all(12), // Veći padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.naziv ?? 'Nema naziva',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // Veći font
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (product.popust != null && product.popust! > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${product.cijena} KM",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 15, // Veći font
                        ),
                      ),
                      Text(
                        "${product.cijena! * (1 - product.popust! / 100)} KM",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15, // Veći font
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    "${product.cijena} KM",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15, // Veći font
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  DataRow _buildDataRow(String label, String? value) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(value ?? 'Nema podataka',
                style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}