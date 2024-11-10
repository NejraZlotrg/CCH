import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/screens/autoservis_details_screen.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AutoservisScreen extends StatefulWidget {
  const AutoservisScreen({super.key});

  @override
  State<AutoservisScreen> createState() => _AutoservisScreenState();
}

class _AutoservisScreenState extends State<AutoservisScreen> {
  late AutoservisProvider _autoservisProvider;
  SearchResult<Autoservis>? result;
  final TextEditingController _nazivGradaController = TextEditingController();
  final TextEditingController _nazivController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoservisProvider = context.read<AutoservisProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Autoservis",
      child: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildCardList()), // Kartični prikaz umjesto DataTable
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Naziv',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: _nazivController,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Naziv grada',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: _nazivGradaController,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  print("Pokretanje pretrage: ${_nazivGradaController.text} i  ${_nazivController.text}");
                  var filterParams = {
                    'IsAllIncluded': 'true',
                  };

                  if (_nazivGradaController.text.isNotEmpty || _nazivController.text.isNotEmpty) {
                    filterParams['nazivGrada'] = _nazivGradaController.text;
                    filterParams['naziv'] = _nazivController.text;
                  }

                  var data = await _autoservisProvider.get(filter: filterParams);

                  if (mounted) { // Provjera da li je widget još uvijek prikazan
                    setState(() {
                      result = data;
                    });
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8.0),
                    Text('Pretraga'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AutoservisDetailsScreen(autoservis: null),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8.0),
                    Text('Dodaj'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCardList() {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      children: result?.result
              .map(
                (Autoservis e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 190.0), // Vanjski padding sa strane
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AutoservisDetailsScreen(autoservis: e),
                          ),
                        );
                      },
                      // Koristimo Row kako bi slika bila sa lijeve strane
                      title: Row(
                        children: [
                          // Slika sa lijeve strane
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding samo s lijeve i desne strane
                            child: Container(
                              width: 200, // Širina slike
                              height: 120, // Povećana visina slike
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(base64Decode(e.slikaProfila ?? "")),
                                  fit: BoxFit.cover, // Slika popunjava cijeli prostor
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0), // Razmak između slike i teksta
                          // Tekst sa desne strane
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding samo s lijeve i desne strane
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end, // Poravnanje teksta na desnu stranu
                                children: [
                                  Text(e.naziv ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Adresa: ${e.adresa ?? ""}'),
                                  Text('Vlasnik: ${e.vlasnikFirme ?? ""}'),
                                  Text('Telefon: ${e.telefon ?? ""}'),
                                  Text('Grad: ${e.grad?.nazivGrada ?? ""}'),
                                  Text('Email: ${e.email ?? ""}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList() ?? 
          [],
    ),
  );
}

}
