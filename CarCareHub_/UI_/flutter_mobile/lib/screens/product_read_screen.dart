// ignore_for_file: use_build_context_synchronously, deprecated_member_use, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';


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
SearchResult<Product>? dataWithDiscount;
  SearchResult<Product>? result2;

  
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
    } 
    if(context.read<UserProvider>().role == "Autoservis") {
      dataWithDiscount = await _productProvider.getForAutoservis( context.read<UserProvider>().userId, filter: {'IsAllIncluded': 'true'});
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
                        _buildProductDetails(),
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
                                          .delete(widget.product!.proizvodId!);

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

 
  
 Widget _buildProductDetails() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.product!.slika != null
                ? Image.memory(
                    base64Decode(widget.product!.slika!),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 200,
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: Text("Nema slike")),
                  ),
          ),
        ),
        const SizedBox(height: 20),

    
        if (widget.product?.naziv != null)
          Text(
            widget.product!.naziv!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 20),

     
        const Text(
          "Opis",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Text(
            widget.product?.opis ?? "Nema opisa",
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 20),

     
        _buildInfoItem("Šifra", widget.product?.sifra),
        _buildInfoItem("Originalni broj", widget.product?.originalniBroj),
        _buildInfoItem("Kategorija", widget.product?.kategorija?.nazivKategorije),
        _buildInfoItem("Proizvođač", widget.product?.proizvodjac?.nazivProizvodjaca),
        _buildInfoItem("Firma autodijelova", widget.product?.firmaAutodijelova?.nazivFirme),
        _buildInfoItem("Model", widget.product?.model?.nazivModela),

        const SizedBox(height: 20),

        _buildPriceSection(),

        const SizedBox(height: 20),

       
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_quantity > 1) _quantity--;
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
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                if (widget.product?.proizvodId != null) {
                  final request = {
                    'proizvodId': widget.product!.proizvodId!,
                    'kolicina': _quantity,
                  };

                  try {
                    await _korpaProvider.insert(request);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Proizvod dodan u korpu.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Greška: ${e.toString()}")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Dodaj u korpu"),
            ),
          ],
        ),

        const SizedBox(height: 40),

      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Preporučeni proizvodi",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 10),
    if (isRecommendationsLoading)
      const Center(child: CircularProgressIndicator())
    else if (recommendedProducts.isEmpty)
      const Center(child: Text("Nema preporučenih proizvoda"))
    else
      ListView.separated(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: recommendedProducts.length,
  separatorBuilder: (_, __) => const SizedBox(height: 16),
  itemBuilder: (context, index) {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: _buildProductCard(recommendedProducts[index], context),
      ),
    );
  },
)

  ],
),

      ],
    ),
  );
}

Widget _buildInfoItem(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value ?? 'Nema podataka')),
      ],
    ),
  );
}

Widget _buildPriceSection() {
  final product = widget.product!;
  final userRole = context.read<UserProvider>().role;
  final hasDiscount = product.popust != null && product.popust! > 0;
  final hasServiceDiscount = product.cijenaSaPopustomZaAutoservis != null &&
      (userRole == "Admin" ||
          (userRole == "Autoservis" &&
              (dataWithDiscount?.result.any((p) => p.proizvodId == product.proizvodId) ?? false)));

  final originalPrice = NumberFormat.currency(locale: 'bs_BA', symbol: '', decimalDigits: 2)
      .format(product.cijena ?? 0);
  final discountedPrice = hasDiscount
      ? NumberFormat.currency(locale: 'bs_BA', symbol: '', decimalDigits: 2)
          .format(product.cijena! * (1 - product.popust! / 100))
      : null;
  final servicePrice = hasServiceDiscount
      ? NumberFormat.currency(locale: 'bs_BA', symbol: '', decimalDigits: 2)
          .format(product.cijenaSaPopustomZaAutoservis!)
      : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Cijena",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      if (hasDiscount || hasServiceDiscount)
        Text(
          "$originalPrice KM",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
        )
      else
        Text(
          "$originalPrice KM",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      if (hasDiscount)
        Text(
          "$discountedPrice KM",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      if (hasServiceDiscount)
        Text(
          "$servicePrice KM",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
    ],
  );
}


Widget _buildProductCard(Product product, BuildContext context) {
  final double cardWidth = MediaQuery.of(context).size.width * 0.5;

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
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
        Align(
  alignment: Alignment.center,
  child: FractionallySizedBox(
    widthFactor: 0.9, 
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        image: product.slika != null
            ? DecorationImage(
                image: MemoryImage(base64Decode(product.slika!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: product.slika == null
          ? const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
          : null,
    ),
  ),
)
,

         
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.naziv ?? 'Nema naziva',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (product.popust != null && product.popust! > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${product.cijena?.toStringAsFixed(2)} KM",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${(product.cijena! * (1 - product.popust! / 100)).toStringAsFixed(2)} KM",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    "${product.cijena?.toStringAsFixed(2)} KM",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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


}