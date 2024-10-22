import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/screens/uloge_details_screen.dart';
import 'package:flutter_mobile/screens/usluge_details_screen.dart';
//import 'package:flutter_mobile/screens/grad_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class UlogeScreen extends StatefulWidget {
  const UlogeScreen({super.key});

  @override
  State<UlogeScreen> createState() => _UlogeScreenState();
}

class _UlogeScreenState extends State<UlogeScreen> {
  late UlogeProvider _ulogeProvider;
  SearchResult<Uloge>? result;
  final TextEditingController _nazivUlogeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ulogeProvider = context.read<UlogeProvider>();
    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Uloge",
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
                labelText: 'Naziv uloge',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivUlogeController,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              print("podaci proceed");
              var data = await _ulogeProvider.get(filter: {
                'nazivUloge': _nazivUlogeController.text,
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
                     MaterialPageRoute(builder: (context)=> UlogeDetailsScreen(uloge: null,) // poziv na drugi screen
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
                'Naziv uloge',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            
          ],
          rows: result?.result
                .map(
                  (Uloge e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.ulogaId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> UlogeDetailsScreen(uloge: e,) // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.nazivUloge ?? "")),
                    ],
                  ),
                )
                .toList() ?? [],
        ),
        ),
    );
  }
}
