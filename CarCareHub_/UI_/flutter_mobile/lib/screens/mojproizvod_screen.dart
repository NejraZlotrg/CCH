import 'dart:convert';
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
  final _formKey = GlobalKey<FormBuilderState>();
  late ModelProvider _modelProvider;
  late VoziloProvider _voziloProvider;
  late GodisteProvider _godisteProvider;
  late GradProvider _gradProvider;

  List<Model>? model;
  List<Vozilo>? vozila;
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
    _initProviders();
    _loadData();
    _loadInitialData();
  }

  void _initProviders() {
    _productProvider = context.read<ProductProvider>();
    _modelProvider = context.read<ModelProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _godisteProvider = context.read<GodisteProvider>();
    _gradProvider = context.read<GradProvider>();
  }

  Future<void> _loadData() async {
    try {
      String? userRole = context.read<UserProvider>().role;
      int? userId = context.read<UserProvider>().userId;
      print("Korisnička uloga: $userRole, korisnicki id: $userId");

      SearchResult<Product> data;

      switch (userRole) {
        case "Admin":
          data = await _productProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
          break;
        case "Firma autodijelova":
          List<Product> products = await _productProvider.getByFirmaAutodijelovaID(userId);
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearch(),
              _buildDataListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Naziv proizvoda
            TextField(
              decoration: const InputDecoration(
                labelText: 'Naziv proizvoda',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivController,
            ),
            const SizedBox(height: 10),

            // Poredaj po cijeni
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Poredaj po cijeni",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['--', 'Rastuća', 'Opadajuća'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _handleSortChange,
            ),
            const SizedBox(height: 10),

            // Naziv firme
            TextField(
              decoration: const InputDecoration(
                labelText: "Naziv firme",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivFirmeController,
            ),
            const SizedBox(height: 10),

            // JIB ili MBS
            TextField(
              decoration: const InputDecoration(
                labelText: "JIB ili MBS",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _JIBMBScontroller,
            ),
            const SizedBox(height: 10),

            // Grad
            FormBuilderDropdown<Grad>(
              name: 'gradId',
              decoration: InputDecoration(
                labelText: 'Lokacija',
                suffixIcon: const Icon(Icons.location_city),
                hintText: 'Odaberite grad',
                hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem<Grad>(value: null, child: Text('Odaberite grad')),
                ...?grad?.map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(
                        g.nazivGrada ?? "",
                        style: TextStyle(
                          color: g.vidljivo == false ? Colors.red : Colors.black,
                        ),
                      ),
                    ))
              ],
            ),
            const SizedBox(height: 10),

            // Dodatne opcije
            ExpansionTile(
              title: const Center(
                child: Text("Dodatne opcije pretrage", style: TextStyle(color: Colors.red)),
              ),
              children: [
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marka vozila
                    FormBuilderDropdown<Vozilo>(
                      name: 'voziloId',
                      decoration: InputDecoration(
                        labelText: 'Marka vozila',
                        suffixIcon: const Icon(Icons.directions_car),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<Vozilo>(value: null, child: Text('Odaberite marku vozila')),
                        ...?vozila?.map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(
                                v.markaVozila ?? "",
                                style: TextStyle(
                                  color: v.vidljivo == false ? Colors.red : Colors.black,
                                ),
                              ),
                            ))
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Godište
                    FormBuilderDropdown<Godiste>(
                      name: 'godisteId',
                      decoration: InputDecoration(
                        labelText: 'Godište',
                        suffixIcon: const Icon(Icons.date_range),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<Godiste>(value: null, child: Text('Odaberite godište')),
                        ...?godiste?.map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g.godiste_?.toString() ?? "",
                                style: TextStyle(
                                  color: g.vidljivo == false ? Colors.red : Colors.black,
                                ),
                              ),
                            ))
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Model
                    FormBuilderDropdown<Model>(
                      name: 'modelId',
                      decoration: InputDecoration(
                        labelText: 'Model',
                        suffixIcon: const Icon(Icons.dashboard_customize),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<Model>(value: null, child: Text('Odaberite model')),
                        ...?model?.map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                m.nazivModela ?? "",
                                style: TextStyle(
                                  color: m.vidljivo == false ? Colors.red : Colors.black,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),

            // Dugmad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (context.read<UserProvider>().role == "Admin" ||
                    context.read<UserProvider>().role == "Firma autodijelova")
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(product: null),
                        ),
                      );
                      await _loadData();
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Dodaj', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _onSearchPressed,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Pretraga', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSortChange(String? value) async {
    if (value == null || value == '--') return;

    final isAdmin = context.read<UserProvider>().role == "Admin";
    final filter = {
      'naziv': _nazivController.text,
      'model': _modelController.text,
      'nazivFirme': _nazivFirmeController.text,
      'nazivGrada': _gradController.text,
      'jib': _JIBMBScontroller.text,
      'mbs': _JIBMBScontroller.text,
      if (value == 'Rastuća') 'cijenaRastuca': true,
      if (value == 'Opadajuća') 'cijenaOpadajuca': true,
    };

    final data = isAdmin
        ? await _productProvider.getAdmin(filter: filter)
        : await _productProvider.get(filter: filter);

    setState(() {
      result = data;
    });
  }

  Future<void> _onSearchPressed() async {
    print("Pokretanje pretrage: ${_nazivController.text}");
    
    Map<dynamic, dynamic> filterParams = {
      'IsAllIncluded': 'true',
    };

    if (_nazivController.text.isNotEmpty) {
      filterParams['naziv'] = _nazivController.text;
    }

    if (_JIBMBScontroller.text.isNotEmpty) {
      filterParams['JIB_MBS'] = _JIBMBScontroller.text;
    }

    if (_nazivFirmeController.text.isNotEmpty) {
      filterParams['nazivFirme'] = _nazivFirmeController.text;
    }

    var selectedVozilo = _formKey.currentState?.fields['voziloId']?.value;
    if (selectedVozilo != null && selectedVozilo is Vozilo) {
      filterParams['markaVozila'] = selectedVozilo.markaVozila!;
    }

    var selectedGrad = _formKey.currentState?.fields['gradId']?.value;
    if (selectedGrad != null && selectedGrad is Grad) {
      filterParams['nazivGrada'] = selectedGrad.nazivGrada!;
    }

    var selectedGodiste = _formKey.currentState?.fields['godisteId']?.value;
    if (selectedGodiste != null && selectedGodiste is Godiste) {
      filterParams['GodisteVozila'] = int.parse(selectedGodiste.godiste_!.toString());
    }

    var modelValue = _formKey.currentState?.fields['modelId']?.value;
    if (modelValue != null && modelValue is Model) {
      filterParams['nazivModela'] = modelValue.nazivModela!;
    }

    try {
      SearchResult<Product> data;
      if (context.read<UserProvider>().role == "Admin") {
        data = await _productProvider.getAdmin(filter: filterParams);
      } else {
        data = await _productProvider.get(filter: filterParams);
      }

      if (mounted) {
        setState(() {
          result = data;
        });
      }
    } catch (e) {
      print("Error during fetching data: $e");
    }
  }

  Widget _buildDataListView() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dvije kolone za mobilni prikaz
          childAspectRatio: 0.75,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: result?.result.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                    // Slika proizvoda
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
                    // Naziv proizvoda
                    Text(
                      e.naziv ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Smanjen font za mobilni
                        color: isHidden ? Colors.red : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Kratak opis proizvoda
                    Text(
                      e.opis != null && e.opis!.length > 20
                          ? "${e.opis!.substring(0, 20)}..."
                          : e.opis ?? "",
                      style: TextStyle(
                        color: isHidden ? Colors.red : Colors.blueGrey,
                        fontSize: 12, // Smanjen font za mobilni
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Cena i dugmad za admina ili firmu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                      await _loadData();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Greška prilikom aktivacije: $e")),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(0, 30), // Smanjena visina dugmeta
                                  ),
                                  child: const Text(
                                    "Prikazi",
                                    style: TextStyle(fontSize: 10), // Smanjen font
                                  ),
                                ),
                              if (e.stateMachine == "active")
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await _productProvider.hideProduct(e.proizvodId!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Proizvod sakriven")),
                                      );
                                      await _loadData();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Greška: $e")),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(0, 30), // Smanjena visina dugmeta
                                  ),
                                  child: const Text(
                                    "Sakrij",
                                    style: TextStyle(fontSize: 10), // Smanjen font
                                  ),
                                ),
                            ],
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (hasDiscount)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "${formatNumber(discountPrice)} KM",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12, // Smanjen font
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "${formatNumber(originalPrice)} KM",
                                style: TextStyle(
                                  color: hasDiscount ? Colors.white70 : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Smanjen font
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
      ),
    );
  }
}