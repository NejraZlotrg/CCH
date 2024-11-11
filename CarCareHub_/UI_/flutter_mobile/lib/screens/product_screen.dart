import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductProvider _productProvider;
  SearchResult<Product>? result;
  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nazivFirmeController = TextEditingController();
  final TextEditingController _gradController = TextEditingController();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Proizvodi",
      child: Column(
        children: [
          _buildSearch(),
          _buildDataListView(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Prvi red za naziv proizvoda
          Row(
            children: [
              SizedBox(
                width: 410, // Postavite željenu širinu
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Naziv proizvoda',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _nazivController,
                ),
              ),
                            const SizedBox(width: 100),

              Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Poredaj po cijeni",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: <String>['--', 'Rastuća', 'Opadajuća']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) async {
      if (value == 'Rastuća') {
        // Call backend for ascending price sort
        var data = await _productProvider.get(filter: {
          'naziv': _nazivController.text,
          'model': _modelController.text,
          'nazivFirme': _nazivFirmeController.text,
          'nazivGrada': _gradController.text,
          'cijenaRastuca': true,  // Specify ascending sort

        });
        setState(() {
          result = data;
        });
      } else if (value == 'Opadajuća') {
        // Call backend for descending price sort
        var data = await _productProvider.get(filter: {
          'naziv': _nazivController.text,
          'model': _modelController.text,
          'nazivFirme': _nazivFirmeController.text,
          'nazivGrada': _gradController.text,
          'cijenaOpadajuca': true,  // Specify descending sort
        });
        setState(() {
          result = data;
        });
      }
    },
  ),
),
            ],
          ),
          const SizedBox(height: 10), // Razmak između redova
          // Drugi red za naziv firme, JIB ili MBS, i model
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Naziv firme",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _nazivFirmeController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "JIB ili MBS",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Lokacija",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _gradController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Razmak između pretraga i dugmadi

          // Ovdje dodajemo dropdown menue unutar ExpansionTile
          ExpansionTile(
            title: const Center(
              // Centriranje naslova
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dodatne opcije pretrage",
                    style:
                        TextStyle(color: Colors.red), // Obojite tekst u crveno
                  ),
                ],
              ),
            ),
            children: [
              Column(
                children: [
                  // Red za marku i godište vozila
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Marka vozila",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: <String>['Marka 1', 'Marka 2', 'Marka 3']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // Logika za promjenu marke vozila
                          },
                        ),
                      ),
                      const SizedBox(width: 10), // Razmak između dropdown-a
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Godište vozila",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: <String>['2020', '2021', '2022', '2023']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // Logika za promjenu godišta vozila
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Razmak između redova

                  // Dropdown za model
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Model",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: <String>['Model 1', 'Model 2', 'Model 3']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      // Logika za promjenu modela
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10), // Razmak između dugmadi
          Row(
  mainAxisAlignment: MainAxisAlignment.end, // Poravnava dugmad desno
  children: [
    ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProductDetailScreen(product: null),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white),
          SizedBox(width: 8.0),
          Text('Dodaj', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
        const SizedBox(width: 10), // Razmak između dugmadi

    ElevatedButton(
      onPressed: () async {
        var data = await _productProvider.get(filter: {
          'naziv': _nazivController.text,
          'model': _modelController.text,
          'nazivFirme': _nazivFirmeController.text,
          'nazivGrada': _gradController.text
        });

        setState(() {
          result = data;
        });
      },
      
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 8.0),
          Text('Pretraga', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const SizedBox(width: 10), // Razmak između dugmadi
    
  ],
),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Tri kolone
            childAspectRatio: 1, // Omjer za kvadratne kartice
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: result?.result.length ?? 0,
          itemBuilder: (context, index) {
            Product e = result!.result[index];
            bool hasDiscount =
                e.cijenaSaPopustom != null && e.cijenaSaPopustom! > 0;
            double originalPrice = e.cijena ?? 0.0;
            double discountPrice = hasDiscount
                ? e.cijenaSaPopustom!
                : e.cijena ?? 0.0; // Cijena sa popustom uvećana za 5%

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: e),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 160,
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: e.slika != null && e.slika!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: Image.memory(
                                    base64Decode(e.slika!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(child: Text("x")),
                        ),
                        const SizedBox(
                            height:
                                25), // Razmak od 25 piksela između slike i naziva
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            top: 4.0,
                          ), // Podiže naziv i opis
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              e.naziv ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20, // Povećan font naziva
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0,
                              top: 2.0,
                              bottom: 14.0), // Podiže opis i ograničava širinu
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: SizedBox(
                              width:
                                  200, // Ograničava širinu opisa na 60% širine kartice
                              child: Text(
                                e.opis != null && e.opis!.length > 30
                                    ? "${e.opis!.substring(0, 30)}..." // Prikazuje samo prvih 30 karaktera
                                    : e.opis ?? "",
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.normal, // Opis nije boldiran
                                ),
                                maxLines: 2,
                                overflow: TextOverflow
                                    .ellipsis, // Omogućava prijelom u novi red
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Column(
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
                                "${formatNumber(discountPrice)} KM", // Cijena sa popustom uvećana za 5%
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      14, // Povećan font za cijenu sa popustom
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
                                color:
                                    hasDiscount ? Colors.white70 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13, // Povećan font za cijenu
                                decoration: hasDiscount
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(150.0),
        ),
      ),
    );
  }
}
