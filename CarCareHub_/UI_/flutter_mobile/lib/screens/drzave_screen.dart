import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/screens/drzave_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class DrzaveScreen extends StatefulWidget {
  const DrzaveScreen({super.key});

  @override
  State<DrzaveScreen> createState() => _DrzaveScreenState();
}

class _DrzaveScreenState extends State<DrzaveScreen> {
  late DrzaveProvider _drzaveProvider;
  SearchResult<Drzave>? result;
  final TextEditingController _nazivDrzaveController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _drzaveProvider = context.read<DrzaveProvider>();
    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Drzava",
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
                labelText: 'Naziv drzave',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivDrzaveController,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              print("podaci proceed");
              var data = await _drzaveProvider.get(filter: {
                'nazivDrzave': _nazivDrzaveController.text,
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
                     MaterialPageRoute(builder: (context)=> DrzaveDetailsScreen(drzava: null,) // poziv na drugi screen
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
                'Naziv drzave',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            
          ],
          rows: result?.result
                .map(
                  (Drzave e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.drzavaId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> DrzaveDetailsScreen(drzava: e,) // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.nazivDrzave ?? "")),
                    ],
                  ),
                )
                .toList() ?? [],
        ),
        ),
    );
  }
}
