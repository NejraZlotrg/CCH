// ignore_for_file: deprecated_member_use, use_build_context_synchronously, non_constant_identifier_names, avoid_print

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
import 'package:flutter_mobile/provider/user_provider.dart';
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
  List<Vozilo>? vozila;
  List<Godiste>? godiste;
  List<Grad>? grad;

  SearchResult<Product>? result;
  SearchResult<Product>? result2;

  Vozilo? selectedVozilo;
  List<Model>? filtriraniModeli;

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
    _loadInitialData();
  }

  @override
  void initState() {
    super.initState();
    filtriraniModeli = model;
  }

  Future<void> _loadData() async {
    try {
      String? userRole = context.read<UserProvider>().role;
      int? userId = context.read<UserProvider>().userId;
      print("Korisnička uloga: $userRole, $userId");

      SearchResult<Product> data;
      SearchResult<Product>? dataWithDiscount;

      switch (userRole) {
        case "Admin":
          data = await _productProvider
              .getAdmin(filter: {'IsAllIncluded': 'true'});
          break;
        case "Klijent":
          data = await _productProvider
              .getForUsers(filter: {'IsAllIncluded': 'true'});
          break;
        case "Autoservis":
          dataWithDiscount = await _productProvider
              .getForAutoservis(userId, filter: {'IsAllIncluded': 'true'});
          data = await _productProvider
              .getForUsers(filter: {'IsAllIncluded': 'true'});
          break;
        default:
          data = await _productProvider.get(filter: {'IsAllIncluded': 'true'});
      }

      if (mounted) {
        setState(() {
          result = data;
          result2 = dataWithDiscount;
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
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildSearch(),
                  ),
                  _buildDataListView(),
                ],
              ),
            ),
          ],
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
            FormBuilderDropdown<Grad>(
              name: 'gradId',
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.location_city),
                hintText: 'Odaberite grad',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem<Grad>(
                  value: null,
                  child: Text('Odaberite grad'),
                ),
                ...?grad?.map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(
                        g.nazivGrada ?? "",
                        style: TextStyle(
                          color:
                              g.vidljivo == false ? Colors.red : Colors.black,
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              title: const Center(
                child: Text("Dodatne opcije pretrage",
                    style: TextStyle(color: Colors.red)),
              ),
              children: [
                FormBuilderDropdown<Vozilo>(
                  name: 'voziloId',
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.directions_car),
                    hintText: 'Odaberite marku vozila',
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
                          child: Text(
                            vozilo.markaVozila ?? "",
                            style: TextStyle(
                              color: vozilo.vidljivo == false
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        )),
                  ],
                  onChanged: (Vozilo? newValue) {
                    setState(() {
                      selectedVozilo = newValue;
                      filtriraniModeli = model
                          ?.where((m) => m.voziloId == selectedVozilo?.voziloId)
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                FormBuilderDropdown<Model>(
                  name: 'modelId',
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.dashboard_customize),
                    hintText: 'Odaberite model',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem<Model>(
                      value: null,
                      child: Text('Odaberite model'),
                    ),
                    ...?filtriraniModeli?.map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m.nazivModela ?? "",
                            style: TextStyle(
                              color: m.vidljivo == false
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                FormBuilderDropdown<Godiste>(
                  name: 'godisteId',
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.date_range),
                    hintText: 'Odaberite godište',
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
                          child: Text(
                            g.godiste_?.toString() ?? "",
                            style: TextStyle(
                              color: g.vidljivo == false
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (context.read<UserProvider>().role == "Admin" ||
                    context.read<UserProvider>().role == "Firma autodijelova")
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProductDetailScreen(product: null),
                        ),
                      );
                      await _loadData();
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Dodaj',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _onSearchPressed,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Pretraga',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataListView() {
    List<Product>? products = result?.result.toList();

    if (products != null && result2 != null && result2!.result.isNotEmpty) {
      products.sort((a, b) {
        bool aInBoth =
            result2!.result.any((prod) => prod.proizvodId == a.proizvodId);
        bool bInBoth =
            result2!.result.any((prod) => prod.proizvodId == b.proizvodId);

        if (aInBoth && !bInBoth) return -1;
        if (!aInBoth && bInBoth) return 1;
        return 0;
      });
    }

    if (products == null || products.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "Nema proizvoda",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            Product e = products[index];
            bool hasDiscount =
                e.cijenaSaPopustom != null && e.cijenaSaPopustom! > 0;
            bool hasServiceDiscount = e.cijenaSaPopustomZaAutoservis != null &&
                e.cijenaSaPopustomZaAutoservis! > 0;
            double originalPrice = e.cijena ?? 0.0;
            double discountPrice =
                hasDiscount ? e.cijenaSaPopustom! : e.cijena ?? 0.0;
            bool isHidden = e.vidljivo == false;
            bool isInDiscountList = result2?.result
                    .any((prod) => prod.proizvodId == e.proizvodId) ??
                false;
            bool isService = context.read<UserProvider>().role == "Autoservis";
            bool isAdmin = context.read<UserProvider>().role == "Admin";

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
                    color: isHidden
                        ? Colors.red
                        : isInDiscountList
                            ? Colors.orange
                            : Colors.transparent,
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
                          fontSize: 16,
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
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                         
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasServiceDiscount &&
                                  (isAdmin || (isService && isInDiscountList)))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "${formatNumber(e.cijenaSaPopustomZaAutoservis!)} KM",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (hasDiscount)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "${formatNumber(discountPrice)} KM",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: (hasDiscount || hasServiceDiscount)
                                      ? 4.0
                                      : 0.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "${formatNumber(originalPrice)} KM",
                                    style: TextStyle(
                                      color: (hasDiscount ||
                                              (hasServiceDiscount &&
                                                  (isAdmin ||
                                                      (isService &&
                                                          isInDiscountList))))
                                          ? Colors.white70
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      decoration: hasDiscount
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                      
                          if ((isAdmin ||
                                  (context.read<UserProvider>().role ==
                                          "Firma autodijelova" &&
                                      context.read<UserProvider>().userId ==
                                          e.firmaAutodijelovaID)) &&
                              e.vidljivo == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      if (e.stateMachine == "draft") {
                                        await _productProvider
                                            .activateProduct(e.proizvodId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Proizvod uspješno prikazan na profilu")),
                                        );
                                      } else if (e.stateMachine == "active") {
                                        await _productProvider
                                            .hideProduct(e.proizvodId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Proizvod uspješno sakriven sa profila")),
                                        );
                                      }
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
                                    backgroundColor: e.stateMachine == "draft"
                                        ? Colors.green
                                        : Colors.red,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    e.stateMachine == "draft"
                                        ? "Prikazi na profilu"
                                        : "Sakrij proizvod",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: products.length,
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

    Map<dynamic, dynamic> filterParams = {'IsAllIncluded': 'true'};

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
      filterParams['GodisteVozila'] =
          int.parse(selectedGodiste.godiste_!.toString());
    }

    var modelValue = _formKey.currentState?.fields['modelId']?.value;
    if (modelValue != null && modelValue is Model) {
      filterParams['nazivModela'] = modelValue.nazivModela!;
    }

    try {
      SearchResult<Product> data;
      SearchResult<Product>? data2;

      if (context.read<UserProvider>().role == "Admin") {
        data = await _productProvider.getAdmin(filter: filterParams);
      } else if (context.read<UserProvider>().role == "Autoservis") {
        var idAutos = context.read<UserProvider>().userId;
        data2 = await _productProvider.getForAutoservis(idAutos,
            filter: filterParams);
        data = await _productProvider.getForAutoservis(idAutos,
            filter: filterParams);
      } else {
        data = await _productProvider.get(filter: filterParams);
      }

      if (mounted) {
        setState(() {
          result = data;
          result2 = data2;
        });
      }
    } catch (e) {
      print("Error during fetching data: $e");
    }
  }
}