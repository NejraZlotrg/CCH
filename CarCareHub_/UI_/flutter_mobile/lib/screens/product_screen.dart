import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
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

  final _formKey = GlobalKey<FormBuilderState>();
  late ModelProvider _modelProvider;
  late VoziloProvider _voziloProvider;
  late GodisteProvider _godisteProvider;

  List<Model>? model;
  List<Vozilo>? vozila; //----- Dodano za vozila
  List<Godiste>? godiste;


  SearchResult<Product>? result;

  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nazivFirmeController = TextEditingController();
  final TextEditingController _gradController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();

    _modelProvider = context.read<ModelProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _godisteProvider = context.read<GodisteProvider>();


    _loadInitialData(); //----- Promijenjeno ime funkcije


   // _loadModel(); ova funkcija zamijenjena sa _loadInitialData
  }

  Future<void> _loadInitialData() async {
    var modelResult = await _modelProvider.get();
    var vozilaResult = await _voziloProvider.get(); //----- Učitavanje vozila
    var godistaResult = await _godisteProvider.get(); //----- Učitavanje godista

    setState(() {
      model = modelResult.result;
      vozila = vozilaResult.result;
      godiste = godistaResult.result;
    });
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
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 410,
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
                        var data = await _productProvider.get(filter: {
                          'naziv': _nazivController.text,
                          'model': _modelController.text,
                          'nazivFirme': _nazivFirmeController.text,
                          'nazivGrada': _gradController.text,
                          'cijenaRastuca': true,
                        });
                        setState(() {
                          result = data;
                        });
                      } else if (value == 'Opadajuća') {
                        var data = await _productProvider.get(filter: {
                          'naziv': _nazivController.text,
                          'model': _modelController.text,
                          'nazivFirme': _nazivFirmeController.text,
                          'nazivGrada': _gradController.text,
                          'cijenaOpadajuca': true,
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            ExpansionTile(
              title: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dodatne opcije pretrage",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown(
                            name: 'voziloId',
                            decoration: InputDecoration(
                              labelText: 'Marka vozila',
                              suffix: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _formKey.currentState!.fields['voziloId']
                                      ?.reset();
                                },
                              ),
                              hintText: 'Odaberite marku vozila',
                            ),
                            items: vozila
                                    ?.map((vozila) => DropdownMenuItem(
                                          value: vozila,
                                          child: Text(vozila.markaVozila ?? ""),
                                        ))
                                    .toList() ??
                                [],
                          ),
                        ),
                        
                        const SizedBox(width: 10),
                        Expanded(
                          child: FormBuilderDropdown(
                            name: 'godisteId',
                            decoration: InputDecoration(
                              labelText: 'Godiste',
                              suffix: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _formKey.currentState!.fields['godisteId']
                                      ?.reset();
                                },
                              ),
                              hintText: 'Odaberite godiste',
                            ),
                            items: godiste
                                    ?.map((godiste) => DropdownMenuItem(
                                          value: godiste,
                                          child: Text(godiste.godiste_!.toString()),
                                        ))
                                    .toList() ??
                                [],
                          ),
                        ),
                        // Dropdown za model
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown(
                            name: 'modelId',
                            decoration: InputDecoration(
                              labelText: 'Model',
                              suffix: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _formKey.currentState!.fields['modelId']
                                      ?.reset();
                                },
                              ),
                              hintText: 'Odaberite model',
                            ),
                            items: model
                                    ?.map((model) => DropdownMenuItem(
                                          value: model,
                                          child: Text(model.nazivModela ?? ""),
                                        ))
                                    .toList() ??
                                [],
                          ),
                        ),
                        
                      ],
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {

                     Navigator.of(context).push(
                     MaterialPageRoute(builder: (context)=> const ProductDetailScreen(product: null,) // poziv na drugi screen
                     ), );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8.0),
                Text('Dodaj'),
              ],
            ),
          ),
                ElevatedButton(
                  onPressed: _onSearchPressed,
                  child: const Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 8.0),
                      Text('Pretraga'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Future<void> _onSearchPressed() async {
  print("Pokretanje pretrage: ${_nazivController.text}");

  var filterParams = {
    'IsAllIncluded': 'true',  // Ovdje navodimo da želimo sve proizvode ako nema specifičnih filtera
  };

  // Dodavanje naziva proizvoda u filter ako je unesen
  if (_nazivController.text.isNotEmpty) {
    filterParams['naziv'] = _nazivController.text;
  }

  // Dodavanje filtera za vozilo, ako je odabrano
  var selectedVozilo = _formKey.currentState?.fields['voziloId']?.value;
  if (selectedVozilo != null && selectedVozilo is Vozilo) {
    filterParams['markaVozila'] = selectedVozilo.markaVozila!;
  }

  // Dodavanje filtera za godiste, ako je odabrano
 var selectedGodiste = _formKey.currentState?.fields['godisteId']?.value;
if (selectedGodiste != null && selectedGodiste is Godiste) {
  // Provjerite ako je godiste_ tipa int i postavite ga direktno
  //filterParams['godiste_'] = selectedGodiste.godiste_;  // Pretvori u string ako je potrebno
}

  // Dodavanje modela, ako je odabran
  var modelValue = _formKey.currentState?.fields['modelId']?.value;
  if (modelValue != null && modelValue is Model) {
    filterParams['nazivModela'] = modelValue.nazivModela!;
  }

  print("Filter params: $filterParams");

  // Pozivanje API-ja sa filterima
  try {
    var data = await _productProvider.get(filter: filterParams);

    if (mounted) {
      setState(() {
        result = data;  // Ažuriraj rezultate sa podacima dobijenim iz backend-a
      });
    }
  } catch (e) {
    print("Error during fetching data: $e");
    // Prikazivanje greške ako dođe do problema pri dohvaćanju podataka
  }
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
