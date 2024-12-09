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
                var filterParams = {
                  'IsAllncluded': 'true', // Ovaj parametar ostaje
                };

                // Dodavanje filtera samo ako je naziv unesen
                if (_nazivDrzaveController.text.isNotEmpty) {
                  filterParams['nazivDrzave'] = _nazivDrzaveController.text;
                }

                var data =
                    await _drzaveProvider.get(filter: filterParams);

                      if (!mounted) return; // Dodaj ovu proveru


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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DrzaveDetailsScreen(
                      drzava: null,
                    ),
                  ),
                );
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
                  Icon(Icons.add), // Ikonica plus
                  SizedBox(width: 8.0),
                  Text('Dodaj'),
                ],
              ),
            ),
            const SizedBox(width: 10),
         
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDataListView() {
  return Container(
    width: MediaQuery.of(context).size.width * 1, // Širina 90% ekrana
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
      child: SingleChildScrollView(
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
    ),
  );
}

}
