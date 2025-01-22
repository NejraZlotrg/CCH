import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
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
  late GradProvider _gradProvider;

  List<Model>? model;
  List<Vozilo>? vozila; //----- Dodano za vozila
  List<Godiste>? godiste;
  List<Grad>? grad;

  SearchResult<Product>? result;

  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nazivFirmeController = TextEditingController();
  final TextEditingController _gradController = TextEditingController();
  final TextEditingController _JIBMBScontroller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _productProvider = context.read<ProductProvider>();

    _modelProvider = context.read<ModelProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _godisteProvider = context.read<GodisteProvider>();
    _gradProvider = context.read<GradProvider>();

    _loadData();
    _loadInitialData(); //----- Promijenjeno ime funkcije


   // _loadModel(); ova funkcija zamijenjena sa _loadInitialData
  }
  Future<void> _loadData() async {
  var data = await _productProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
  }
}

  Future<void> _loadInitialData() async {
    var modelResult = await _modelProvider.get();
    var vozilaResult = await _voziloProvider.get(); //----- Učitavanje vozila
    var godistaResult = await _godisteProvider.get(); //----- Učitavanje godista
    var gradResult = await _gradProvider.get(); //----- Učitavanje godista

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
      color: const Color.fromARGB(255, 204, 204, 204), // Dodana siva pozadina
      child: Column(
        children: [
          _buildSearch(),
          _buildDataListView(),
        ],
      ),
      )
    );
  }

Widget _buildSearch() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Istaknuto polje za naziv proizvoda
          TextField(
            decoration: const InputDecoration(
              labelText: 'Naziv proizvoda',
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: _nazivController,
          ),          const SizedBox(height: 10),

          // Dropdown za sortiranje po cijeni
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Poredaj po cijeni",
              border: OutlineInputBorder(),
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
                  'jib': _JIBMBScontroller.text,
                  'mbs': _JIBMBScontroller.text,
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
                  'jib': _JIBMBScontroller.text,
                  'mbs': _JIBMBScontroller.text,
                  'cijenaOpadajuca': true,
                });
                setState(() {
                  result = data;
                });
              }
            },
          ),
          const SizedBox(height: 10),

 

          // Dodatne opcije pretrage
          ExpansionTile(
            title: const Text(
              "Dodatne opcije pretrage",
              style: TextStyle(color: Colors.red),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          
          FormBuilderDropdown<Grad>(
            name: 'gradId',
            decoration: const InputDecoration(
              labelText: 'Lokacija',
              suffixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem<Grad>(
                value: null,
                child: Text('Odaberite grad'),
              ),
              ...?grad?.map((grad) => DropdownMenuItem(
                    value: grad,
                    child: Text(grad.nazivGrada ?? ''),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          // Polja jedno ispod drugog
          TextField(
            decoration: const InputDecoration(
              labelText: 'Naziv firme',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: _nazivFirmeController,
          ),
          const SizedBox(height: 10),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'JIB ili MBS',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: _JIBMBScontroller,
          ),
          const SizedBox(height: 10),

                  FormBuilderDropdown<Vozilo>(
                    name: 'voziloId',
                    decoration: const InputDecoration(
                      labelText: 'Marka vozila',
                      suffixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem<Vozilo>(
                        value: null,
                        child: Text('Odaberite marku vozila'),
                      ),
                      ...?vozila?.map((vozilo) => DropdownMenuItem(
                            value: vozilo,
                            child: Text(vozilo.markaVozila ?? ''),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FormBuilderDropdown<Godiste>(
                    name: 'godisteId',
                    decoration: const InputDecoration(
                      labelText: 'Godište',
                      suffixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem<Godiste>(
                        value: null,
                        child: Text('Odaberite godište'),
                      ),
                      ...?godiste?.map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.godiste_!.toString()),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FormBuilderDropdown<Model>(
                    name: 'modelId',
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      suffixIcon: Icon(Icons.dashboard_customize),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem<Model>(
                        value: null,
                        child: Text('Odaberite model'),
                      ),
                      ...?model?.map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.nazivModela ?? ''),
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Dugmad za pretragu
Align(
  alignment: Alignment.centerRight,
  child: SizedBox(
    width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
    child: ElevatedButton.icon(
      onPressed: _onSearchPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10), // Povećava visinu dugmeta
      ),
      icon: const Icon(Icons.search, color: Colors.white),
      label: const Text(
        "Pretraži",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14, // Veličina teksta
        ),
      ),
    ),
    
  ),
),
      Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProductDetailScreen(product: null),
                ),
              );
              await _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Crvena boja za dugme
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Dodaj', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    

        ],
      ),
    ),
  );
}

Future<void> _onSearchPressed() async {
  print("Pokretanje pretrage: ${_nazivController.text}");
  
Map<dynamic, dynamic> filterParams = {};

    filterParams = {
    'IsAllIncluded': 'true',  // Ovdje navodimo da želimo sve proizvode ako nema specifičnih filtera

  };



  // Dodavanje naziva proizvoda u filter ako je unesen
  if (_nazivController.text.isNotEmpty) {
    filterParams['naziv'] = _nazivController.text;
  }


  // Dodavanje naziva proizvoda u filter ako je unesen
  if (_JIBMBScontroller.text.isNotEmpty) {
    filterParams['JIB_MBS'] = _JIBMBScontroller.text;
  }



// Dodavanje naziva proizvoda u filter ako je unesen
  if (_nazivFirmeController.text.isNotEmpty) {
    filterParams['nazivFirme'] = _nazivFirmeController.text;
  }
  // Dodavanje filtera za vozilo, ako je odabrano
  var selectedVozilo = _formKey.currentState?.fields['voziloId']?.value;
  if (selectedVozilo != null && selectedVozilo is Vozilo) {
    filterParams['markaVozila'] = selectedVozilo.markaVozila!;
  }


  // Dodavanje filtera za grad, ako je odabran
  var selectedGrad = _formKey.currentState?.fields['gradId']?.value;
  if (selectedGrad != null && selectedGrad is Grad) {
    filterParams['nazivGrada'] = selectedGrad.nazivGrada!;
  }

  // Dodavanje filtera za godiste, ako je odabrano
 var selectedGodiste = _formKey.currentState?.fields['godisteId']?.value;
if (selectedGodiste != null && selectedGodiste is Godiste) {
  filterParams['GodisteVozila'] = int.parse(selectedGodiste.godiste_!.toString());
}


  // Dodavanje modela, ako je odabran 
  var modelValue = _formKey.currentState?.fields['modelId']?.value;
  if (modelValue != null && modelValue is Model) {
    filterParams['nazivModela'] = modelValue.nazivModela!;
  }

   
  

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
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
        ),
        itemCount: result?.result.length ?? 0,
        itemBuilder: (context, index) {
          Product e = result!.result[index];
          bool hasDiscount = e.cijenaSaPopustom != null &&
              e.cijenaSaPopustom! > 0 &&
              e.cijenaSaPopustom! < (e.cijena ?? 0.0);
          double originalPrice = e.cijena ?? 0.0;
          double discountPrice = hasDiscount ? e.cijenaSaPopustom! : 0.0;

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: e),
                ),
              );

              await _loadData();
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 0.25,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                    child: e.slika != null && e.slika!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            child: Image.memory(
                              base64Decode(e.slika!),
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image, size: 30, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      e.naziv ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      e.opis != null && e.opis!.length > 15
                          ? "${e.opis!.substring(0, 15)}..."
                          : e.opis ?? "",
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${formatNumber(discountPrice)} KM",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (hasDiscount) const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasDiscount
                                // ignore: deprecated_member_use
                                ? Colors.blueGrey.withOpacity(0.7)
                                // ignore: deprecated_member_use
                                : Colors.blueGrey.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${formatNumber(originalPrice)} KM",
                            style: TextStyle(
                              color: hasDiscount ? Colors.white70 : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              decoration: hasDiscount ? TextDecoration.lineThrough : TextDecoration.none,
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
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      ),
    ),
  );
}

}