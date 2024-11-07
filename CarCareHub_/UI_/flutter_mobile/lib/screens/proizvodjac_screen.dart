import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/proizvodjac_provider.dart';
import 'package:flutter_mobile/screens/drzave_details_screen.dart';
import 'package:flutter_mobile/screens/proizvodjac_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ProizvodjacScreen extends StatefulWidget {
  const ProizvodjacScreen({super.key});

  @override
  State<ProizvodjacScreen> createState() => _ProizvodjacScreenState();
}

class _ProizvodjacScreenState extends State<ProizvodjacScreen> {
  late ProizvodjacProvider _proizvodjacProvider;
  SearchResult<Proizvodjac>? result;
  final TextEditingController _nazivProizvodjacaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _proizvodjacProvider = context.read<ProizvodjacProvider>();
    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Proizvodjac",
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Naziv proizvodjaca',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivProizvodjacaController,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              print("podaci proceed");
              var data = await _proizvodjacProvider.get(filter: {
                'nazivDrzave': _nazivProizvodjacaController.text,
              });

              setState(() {
                result = data;
              });
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8.0),
                Text('Pretraga'),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {

                     Navigator.of(context).push(
                     MaterialPageRoute(builder: (context)=> ProizvodjacDetailsScreen(proizvodjac: null,) // poziv na drugi screen
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
        ],
      ),
    );
  }

  Widget _buildDataListView() {
  return Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical, // Vertikalni pomak
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Naziv proizvodjaca',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            
          ],
          rows: result?.result
                .map(
                  (Proizvodjac e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.proizvodjacId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> ProizvodjacDetailsScreen(proizvodjac: e,) // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.nazivProizvodjaca ?? "")),
                    ],
                  ),
                )
                .toList() ?? [],
        ),
        ),
    );
  }
}
