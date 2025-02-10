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
  try {
    String? userRole = context.read<UserProvider>().role;
    print("Korisnička uloga: ${userRole ?? 'Nepoznata'}");

    SearchResult<Product> data;

    switch (userRole) {
      case "Admin":
        data = await _productProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
        break;
      case "Klijent":
        data = await _productProvider.getForUsers(filter: {'IsAllIncluded': 'true'});
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
     if (context.read<UserProvider>().role == "Admin"){
    modelResult = await _modelProvider.getAdmin();
    vozilaResult = await _voziloProvider.getAdmin(); //----- Učitavanje vozila
    godistaResult = await _godisteProvider.getAdmin(); //----- Učitavanje godista
    gradResult = await _gradProvider.getAdmin(); //----- Učitavanje godista
}
else {
    modelResult = await _modelProvider.get();
    vozilaResult = await _voziloProvider.get(); //----- Učitavanje vozila
    godistaResult = await _godisteProvider.get(); //----- Učitavanje godista
    gradResult = await _gradProvider.get(); //----- Učitavanje godista
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
          children: [
            Row(
              children: [
                SizedBox(
                  width: 410,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Naziv proizvoda',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: _nazivController,
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                      SearchResult<Product> data;
                      if (value == 'Rastuća') {
                         if (context.read<UserProvider>().role == "Admin"){
                        data = await _productProvider.getAdmin(filter: {
                          'naziv': _nazivController.text,
                          'model': _modelController.text,
                          'nazivFirme': _nazivFirmeController.text,
                          'nazivGrada': _gradController.text,
                          'jib': _JIBMBScontroller.text,
                          'mbs': _JIBMBScontroller.text,
                          'cijenaRastuca': true,
                        });} 
                        else {
                        data = await _productProvider.get(filter: {
                          'naziv': _nazivController.text,
                          'model': _modelController.text,
                          'nazivFirme': _nazivFirmeController.text,
                          'nazivGrada': _gradController.text,
                          'jib': _JIBMBScontroller.text,
                          'mbs': _JIBMBScontroller.text,
                          'cijenaRastuca': true,
                        });} 
                        setState(() {
                          result = data;
                        }); 
                      } else if (value == 'Opadajuća') {
                        SearchResult<Product> data;
                        if (context.read<UserProvider>().role == "Admin"){
                        data = await _productProvider.getAdmin(filter: {
                          'naziv': _nazivController.text,
                          'model': _modelController.text,
                          'nazivFirme': _nazivFirmeController.text,
                          'nazivGrada': _gradController.text,
                          'jib': _JIBMBScontroller.text,
                          'mbs': _JIBMBScontroller.text,
                          'cijenaOpadajuca': true,
                        });}
                        else {
                        data = await _productProvider.get(filter: {
                          'naziv': _nazivController.text,
                          'model': _modelController.text,
                          'nazivFirme': _nazivFirmeController.text,
                          'nazivGrada': _gradController.text,
                          'jib': _JIBMBScontroller.text,
                          'mbs': _JIBMBScontroller.text,
                          'cijenaOpadajuca': true,
                        });}
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
                    decoration: const InputDecoration(
                      labelText: "Naziv firme",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: _nazivFirmeController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "JIB ili MBS",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: _JIBMBScontroller,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
          child: FormBuilderDropdown<Grad>(
  name: 'gradId',
  decoration: InputDecoration(
    labelText: 'Lokacija',
    suffixIcon: const Icon(Icons.directions_car),
    hintText: 'Odaberite grad',
    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
    border: const OutlineInputBorder(),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
  items: [
    const DropdownMenuItem<Grad>(
      value: null,
      child: Text('Odaberite grad'),
    ),
  ] +
      (grad
              ?.map((grad) => DropdownMenuItem(
                    value: grad,
                    child: Text(
                      grad.nazivGrada ?? "",
                      style: TextStyle(
                        color: grad.vidljivo == false ? Colors.red : Colors.black,
                      ),
                    ),
                  ))
              .toList() ??
          []),
)

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
          child: FormBuilderDropdown<Vozilo>(
  name: 'voziloId',
  decoration: InputDecoration(
    labelText: 'Marka vozila',
    suffixIcon: const Icon(Icons.directions_car),
    hintText: 'Odaberite marku vozila',
    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
    border: const OutlineInputBorder(),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
  items: [
    const DropdownMenuItem<Vozilo>(
      value: null,
      child: Text('Odaberite marku vozila'),
    ),
  ] +
      (vozila
              ?.map((vozilo) => DropdownMenuItem(
                    value: vozilo,
                    child: Text(
                      vozilo.markaVozila ?? "",
                      style: TextStyle(
                        color: vozilo.vidljivo == false ? Colors.red : Colors.black,
                      ),
                    ),
                  ))
              .toList() ??
          []),
)

        ),
        const SizedBox(width: 16), // Razmak između dropdown-ova
        Expanded(
          child: FormBuilderDropdown<Godiste>(
  name: 'godisteId',
  decoration: InputDecoration(
    labelText: 'Godiste',
    suffixIcon: const Icon(Icons.date_range),
    hintText: 'Odaberite godiste',
    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
    border: const OutlineInputBorder(),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
  items: [
    const DropdownMenuItem<Godiste>(
      value: null,
      child: Text('Odaberite godiste'),
    ),
  ] +
      (godiste
              ?.map((god) => DropdownMenuItem(
                    value: god,
                    child: Text(
                      god.godiste_?.toString() ?? "",
                      style: TextStyle(
                        color: god.vidljivo == false ? Colors.red : Colors.black,
                      ),
                    ),
                  ))
              .toList() ??
          []),
)

        ),
      ],
    ),
    const SizedBox(height: 16), // Razmak između redova
    Row(
      children: [
        Expanded(
  child: FormBuilderDropdown<Model>(
  name: 'modelId',
  decoration: InputDecoration(
    labelText: 'Model',
    suffixIcon: const Icon(Icons.dashboard_customize),
    hintText: 'Odaberite model',
    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
    border: const OutlineInputBorder(),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
  items: [
    const DropdownMenuItem<Model>(
      value: null,
      child: Text('Odaberite model'),
    ),
  ] +
      (model
              ?.map((model) => DropdownMenuItem(
                    value: model,
                    child: Text(
                      model.nazivModela ?? "",
                      style: TextStyle(
                        color: model.vidljivo == false ? Colors.red : Colors.black,
                      ),
                    ),
                  ))
              .toList() ??
          []),
)

),

      ],
    ),
  ],
)

              ],
            ),
            Row(
  mainAxisAlignment: MainAxisAlignment.end, // Elemente poravnaj desno
  children: [
    ElevatedButton(
      onPressed: () async {
                    await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProductDetailScreen(product: null),
                              ),
                            );
                    await _loadData();

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Crvena boja za dugme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min, // Minimalna veličina dugmeta
        children: [
          Icon(Icons.add, color: Colors.white),
          SizedBox(width: 8.0), // Razmak između ikone i teksta
          Text('Dodaj', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
    const SizedBox(width: 10), // Razmak između dva dugmeta
    ElevatedButton(
      onPressed: _onSearchPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Crvena boja za dugme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min, // Minimalna veličina dugmeta
        children: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 8.0), // Razmak između ikone i teksta
          Text('Pretraga', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
  ],
)

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
    SearchResult<Product> data;
    if (context.read<UserProvider>().role == "Admin")
     data = await _productProvider.getAdmin(filter: filterParams);
    else 
     data = await _productProvider.get(filter: filterParams);


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
          childAspectRatio: 0.75, // Omjer za kartice da se ne preklapaju
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: result?.result.length ?? 0,
        itemBuilder: (context, index) {
          Product e = result!.result[index];
          bool hasDiscount = e.cijenaSaPopustom != null && e.cijenaSaPopustom! > 0;
          double originalPrice = e.cijena ?? 0.0;
          double discountPrice = hasDiscount ? e.cijenaSaPopustom! : e.cijena ?? 0.0;
          bool isHidden = e.vidljivo == false;

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: e),
                ),
              );
              await _loadData(); // Osvježi podatke nakon povratka
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
                    // Slika proizvoda
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: e.slika != null && e.slika!.isNotEmpty
                            ? Image.memory(
                                base64Decode(e.slika!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : const Center(child: Text("Nema slike")),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Naziv proizvoda
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
                    // Kratak opis proizvoda
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
                    // Cena i dugmad za admina ili firmu
             Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Admin ili firma može videti dugmad, samo ako je proizvod vidljiv
    if ((context.read<UserProvider>().role == "Admin" ||
        (context.read<UserProvider>().role == "Firma autodijelova" &&
            context.read<UserProvider>().userId == e.firmaAutodijelovaID)) &&
        e.vidljivo == true)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (e.stateMachine == "draft")
            ElevatedButton(
              onPressed: () async {
                try {
                  await _productProvider.activateProduct(e.proizvodId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Proizvod uspješno prikazan na profilu")),
                  );
                  await _loadData(); // Osvježavanje podataka nakon aktivacije
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Greška prilikom aktivacije: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  await _productProvider.hideProduct(e.proizvodId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Proizvod uspješno sakriven sa profila")),
                  );
                  await _loadData(); // Osvježavanje podataka nakon aktivacije
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Greška prilikom aktivacije: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                "Sakri proizvod",
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.7),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            "${formatNumber(originalPrice)} KM",
            style: TextStyle(
              color: hasDiscount ? Colors.white70 : Colors.white,
              fontWeight: FontWeight.bold,
              decoration: hasDiscount ? TextDecoration.lineThrough : null,
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