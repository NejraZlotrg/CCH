import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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
   _fetchInitialData();
  }
  Future<void> _fetchInitialData() async {
    try {
      var data = await _proizvodjacProvider.get(filter: {
        'IsAllncluded': 'true',
      });
      if (mounted) {
        setState(() {
          result = data;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Proizvodjac",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204), // Dodana siva pozadina
        child: Column(
          children: [
            _buildSearch(),
            _buildDataListView(),
          ],
        ),
      ),
    );
  }

 
  Widget _buildSearch() {
  return Container(
    width: MediaQuery.of(context).size.width, // Širina 100% ekrana
    margin: const EdgeInsets.only(
      top: 20.0, // Razmak od vrha
    ),
    child: Card(
      elevation: 4.0, // Dodaje malo sjene za karticu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0), // Zaobljeni uglovi kartice
        side: const BorderSide(
          color: Colors.black, // Crni okvir
          width: 1.0, // Debljina okvira (1px)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
                'nazivProizvodjaca': _nazivProizvodjacaController.text,
              });
 
              setState(() {
                result = data;
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Crvena boja dugmeta
                foregroundColor: Colors.white, // Bijela boja teksta
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Zaobljeni uglovi
                ),
              ),
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
                    await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProizvodjacDetailsScreen(proizvodjac: null),
                              ),
                            );
                    await _fetchInitialData();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Crvena boja dugmeta
                foregroundColor: Colors.white, // Bijela boja teksta
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Zaobljeni uglovi
                ),
              ),
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
      ),)
    );
  }
Widget _buildDataListView() {
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(top: 20.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      child: SingleChildScrollView(
        child: DataTable(
                    showCheckboxColumn: false,

          columns: const [
            DataColumn(
              label: Text(
                'Naziv proizvođača',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                   .map(
                      (Proizvodjac e) => DataRow(
                        onSelectChanged: (selected) async  {
                          if (selected == true) {
                           await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProizvodjacDetailsScreen(proizvodjac: e),
                              ),
                            );
                    await _fetchInitialData();

                  }
                },
                cells: [
                  DataCell(Text(e.nazivProizvodjaca.toString())),
                ],
             
                      ),
                    )
                    .toList() ??
                [],
          ),
        ),
      ),
    );
  }
}

 