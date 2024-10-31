import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/autoservis_usluge.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_usluge_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AutoservisUslugeScreen extends StatefulWidget {
  const AutoservisUslugeScreen({super.key});

  @override
  State<AutoservisUslugeScreen> createState() => _AutoservisUslugeScreenState();
}

class _AutoservisUslugeScreenState extends State<AutoservisUslugeScreen> {
  late AutoservisUslugeProvider _autoservisuslugeProvider;
  SearchResult<AutoservisUsluge>? result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoservisuslugeProvider = context.read<AutoservisUslugeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Autoservis",
      child: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildDataTable()), // Omogućavanje skrolanja unutar tabele
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(  // Polja za pretragu postavljena jedno ispod drugog
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Naziv',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  print("Pretraga podataka");
                
                   var filterParams = {
    'IsAllIncluded': 'true', // Ovaj parametar ostaje
  };
 // Dodavanje filtera samo ako je naziv unesen
 // if (conf.text.isNotEmpty) {
  //  filterParams['Naziv'] = _nazivGradaController.text;
  //}

  var data = await _autoservisuslugeProvider.get(filter: filterParams);

                  setState(() {
                    result = data;
                  });
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
                  // Ovdje možete dodati logiku za dodavanje nove usluge
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

  Widget _buildDataTable() {
    return SingleChildScrollView(  // Omogućavanje vodoravnog skrolanja
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Naziv')),
        ],
        rows: result?.result
                .map(
                  (AutoservisUsluge e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.autoservisUslugeId}');
                        // Dodavanje logike za navigaciju ili akciju za detalje
                      }
                    },
                    cells: [
                      DataCell(Text(e.autoservisUslugeId.toString())),
                      DataCell(Text(e.autoservis?.naziv ?? "")),
                    ],
                  ),
                )
                .toList() ??
            [],
      ),
    );
  }
}
