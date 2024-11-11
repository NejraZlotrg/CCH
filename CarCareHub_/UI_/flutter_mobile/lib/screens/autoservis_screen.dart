import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/screens/autoservis_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AutoservisScreen extends StatefulWidget {
  const AutoservisScreen({super.key});

  @override
  State<AutoservisScreen> createState() => _AutoservisScreenState();
}

class _AutoservisScreenState extends State<AutoservisScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late AutoservisProvider _autoservisProvider;
  late GradProvider _gradProvider;

  SearchResult<Autoservis>? result;
  List<Grad>? gradovi;

  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _nazivGradaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoservisProvider = context.read<AutoservisProvider>();
    _gradProvider = context.read<GradProvider>();

    // Učitaj gradove kada widget postane dio widget drveta
    _loadGradovi();
  }

  Future<void> _loadGradovi() async {
    var gradoviResult = await _gradProvider.get();
    setState(() {
      gradovi = gradoviResult.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Autoservis",
      child: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildCardList()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return FormBuilder(
      key: _formKey,
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
          FormBuilderDropdown(
  name: 'gradId',
  decoration: InputDecoration(
    labelText: 'Grad',
    suffix: IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        _formKey.currentState!.fields['gradId']?.reset();
      },
    ),
    hintText: 'Odaberite grad',
  ),
  items: gradovi
      ?.map((grad) => DropdownMenuItem(
            value: grad.nazivGrada,  // Promjena: šaljemo nazivGrada
            child: Text(grad.nazivGrada ?? ""),
          ))
      .toList() ?? [],
)
,
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AutoservisDetailsScreen(autoservis: null),
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

 Future<void> _onSearchPressed() async {
  print("Pokretanje pretrage: ${_nazivController.text}");

  var filterParams = {
    'IsAllIncluded': 'true',
  };

  // Dodavanje naziva u filter ako je unesen
  if (_nazivController.text.isNotEmpty) {
    filterParams['naziv'] = _nazivController.text;
  }

  // Dodavanje naziva grada u filter ako je odabran
  var nazivGradaValue = _formKey.currentState?.fields['gradId']?.value;
  if (nazivGradaValue != null) {
    print("Odabrani naziv grada: $nazivGradaValue"); // Debug izlaz za odabrani grad
    filterParams['nazivGrada'] = nazivGradaValue.toString();
  } else {
    print("Grad nije odabran."); // Debug ako grad nije odabran
  }

  print("Filter params: $filterParams");

  // Pozivanje API-ja sa filterima
  var data = await _autoservisProvider.get(filter: filterParams);

  if (mounted) {
    setState(() {
      result = data; // Ažuriraj rezultate sa podacima dobijenim iz backend-a
    });
  }
}


  Widget _buildCardList() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: result?.result
                .map(
                  (Autoservis e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 190.0),
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
                              builder: (context) =>
                                  AutoservisDetailsScreen(autoservis: e),
                            ),
                          );
                        },
                        title: Row(
                          children: [
                            Container(
                              width: 200,
                              height: 150,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(
                                      base64Decode(e.slikaProfila ?? "")),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    e.naziv ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Adresa: ${e.adresa ?? ""}',
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Grad: ${e.grad?.nazivGrada ?? ""}',
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Telefon: ${e.telefon ?? ""}',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
