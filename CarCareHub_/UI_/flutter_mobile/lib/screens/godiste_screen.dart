import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/screens/godiste_details_screen.dart';
//import 'package:flutter_mobile/screens/godiste_details_screen.dart';
//import 'package:flutter_mobile/screens/drzave_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class GodisteScreen extends StatefulWidget {
  const GodisteScreen({super.key});

  @override
  State<GodisteScreen> createState() => _GodisteScreenState();
}

class _GodisteScreenState extends State<GodisteScreen> {
  late GodisteProvider _godisteProvider;
  SearchResult<Godiste>? result;
  final TextEditingController _nazivModelaController = TextEditingController(); //popraviti

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _godisteProvider = context.read<GodisteProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
  var data = await _godisteProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Godiste",
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
                  labelText: 'Godiste:',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: _nazivModelaController,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                var filterParams = {
                  'IsAllncluded': 'true', // Ovaj parametar ostaje
                };

                // Dodavanje filtera samo ako je naziv unesen
                if (_nazivModelaController.text.isNotEmpty) {
                  filterParams['godiste_'] = _nazivModelaController.text;
                }

                var data =
                    await _godisteProvider.get(filter: filterParams);

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
                   if (context.read<UserProvider>().role == "Admin")
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GodisteDetailsScreen(
                      godiste: null,
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
                'Godiste: ',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            
          ],
          rows: result?.result
                .map(
                  (Godiste e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.godisteId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> GodisteDetailsScreen(godiste: e,) // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.godiste_.toString())),
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
