// ignore_for_file: non_constant_identifier_names, deprecated_member_use, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/screens/product_read_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class MojProizvodScreen extends StatefulWidget {
  const MojProizvodScreen({super.key});

  @override
  State<MojProizvodScreen> createState() => _MojProizvodScreenState();
}

class _MojProizvodScreenState extends State<MojProizvodScreen> {
  late ProductProvider _productProvider;

  late ModelProvider _modelProvider;
  late VoziloProvider _voziloProvider;
  late GodisteProvider _godisteProvider;
  late GradProvider _gradProvider;

  List<Model>? model;
  List<Vozilo>? vozila;
  List<Godiste>? godiste;
  List<Grad>? grad;

  SearchResult<Product>? result;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _productProvider = context.read<ProductProvider>();

    _modelProvider = context.read<ModelProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _godisteProvider = context.read<GodisteProvider>();
    _gradProvider = context.read<GradProvider>();

    _loadData();
    _loadInitialData();
  }

  Future<void> _loadData() async {
    try {
      String? userRole = context.read<UserProvider>().role;
      int? userId = context.read<UserProvider>().userId;
      print("Korisnička uloga: $userRole");
      print(", korisnicki id: $userId");

      SearchResult<Product> data;

      switch (userRole) {
        case "Admin":
          data = await _productProvider
              .getAdmin(filter: {'IsAllIncluded': 'true'});
          break;
        case "Firma autodijelova":
          List<Product> products =
              await _productProvider.getByFirmaAutodijelovaID(userId);
          data = SearchResult<Product>()
            ..result = products
            ..count = products.length;
          break;
        default:
          data = await _productProvider.get(filter: {'IsAllIncluded': 'true'});
      }

      if (mounted) {
        setState(() {
          result = data;
        });
      }
    } catch (e) {
      print("Došlo je do greške prilikom učitavanja podataka: $e");
    }
  }

  Future<void> _loadInitialData() async {
    SearchResult<Model> modelResult;
    SearchResult<Vozilo> vozilaResult;
    SearchResult<Godiste> godistaResult;
    SearchResult<Grad> gradResult;
    if (context.read<UserProvider>().role == "Admin") {
      modelResult = await _modelProvider.getAdmin();
      vozilaResult = await _voziloProvider.getAdmin();
      godistaResult = await _godisteProvider.getAdmin();
      gradResult = await _gradProvider.getAdmin();
    } else {
      modelResult = await _modelProvider.get();
      vozilaResult = await _voziloProvider.get();
      godistaResult = await _godisteProvider.get();
      gradResult = await _gradProvider.get();
    }
    setState(() {
      model = modelResult.result;
      vozila = vozilaResult.result;
      godiste = godistaResult.result;
      grad = gradResult.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: "Proizvodi",
        child: Container(
          color: const Color.fromARGB(255, 204, 204, 204),
          child: Column(
            children: [
              _buildDataListView(),
            ],
          ),
        ));
  }

 

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 6.0,
            mainAxisSpacing: 6.0,
          ),
          itemCount: result?.result.length ?? 0,
          itemBuilder: (context, index) {
            Product e = result!.result[index];
            bool hasDiscount =
                e.cijenaSaPopustom != null && e.cijenaSaPopustom! > 0;
            double originalPrice = e.cijena ?? 0.0;
            double discountPrice =
                hasDiscount ? e.cijenaSaPopustom! : e.cijena ?? 0.0;
            bool isHidden = e.vidljivo == false;

            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductReadScreen(product: e),
                  ),
                );
                await _loadData();
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isHidden ? Colors.red : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: e.slika != null && e.slika!.isNotEmpty
                              ? Image.memory(
                                  base64Decode(e.slika!),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                )
                              : const Center(child: Text("Nema slike")),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.naziv ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isHidden ? Colors.red : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.opis != null && e.opis!.length > 30
                            ? "${e.opis!.substring(0, 30)}..."
                            : e.opis ?? "",
                        style: TextStyle(
                          color: isHidden ? Colors.red : Colors.blueGrey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if ((context.read<UserProvider>().role == "Admin" ||
                                  (context.read<UserProvider>().role ==
                                          "Firma autodijelova" &&
                                      context.read<UserProvider>().userId ==
                                          e.firmaAutodijelovaID)) &&
                              e.vidljivo == true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (e.stateMachine == "draft")
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await _productProvider
                                            .activateProduct(e.proizvodId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Proizvod uspješno prikazan na profilu")),
                                        );
                                        await _loadData();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Greška prilikom aktivacije: $e")),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                    ),
                                    child: const Text(
                                      "Prikazi na profilu",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                if (e.stateMachine == "active")
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await _productProvider
                                            .hideProduct(e.proizvodId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Proizvod uspješno sakriven sa profila")),
                                        );
                                        await _loadData();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Greška prilikom aktivacije: $e")),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                    ),
                                    child: const Text(
                                      "Sakrij proizvod",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasDiscount)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "${formatNumber(discountPrice)} KM",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "${formatNumber(originalPrice)} KM",
                                  style: TextStyle(
                                    color: hasDiscount
                                        ? Colors.white70
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: hasDiscount
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}
