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
      child: Container(
        color: Colors.grey[200], // Postavlja pozadinu ekrana na sivu
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildCardList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return FormBuilder(
      key: _formKey,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Naziv',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: _nazivController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
          child: FormBuilderDropdown<Grad>(
            name: 'gradId',
            decoration: InputDecoration(
              labelText: 'Grad',
              suffixIcon: const Icon(Icons.location_city),
              hintText: 'Odaberite grad',
              hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            items: gradovi
                    ?.map((grad) => DropdownMenuItem(
                          value: grad,
                          child: Text(grad.nazivGrada ?? ""),
                        ))
                    .toList() ??
                [],
          ),
        ),
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AutoservisDetailsScreen(autoservis: null),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Crvena boja
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text('Dodaj', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
              const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _onSearchPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Crvena boja
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text('Pretraga', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      print("Odabrani naziv grada: $nazivGradaValue");
      filterParams['nazivGrada'] = nazivGradaValue.toString();
    }

    print("Filter params: $filterParams");

    // Pozivanje API-ja sa filterima
    var data = await _autoservisProvider.get(filter: filterParams);

    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  Widget _buildCardList() {
    return ListView.builder(
      itemCount: result?.result.length ?? 0,
      itemBuilder: (context, index) {
        var e = result!.result[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(e.slikaProfila ?? "")),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.naziv ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text('Adresa: ${e.adresa ?? ""}'),
                        Text('Grad: ${e.grad?.nazivGrada ?? ""}'),
                        Text('Telefon: ${e.telefon ?? ""}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
