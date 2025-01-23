import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/screens/grad_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class GradScreen extends StatefulWidget {
  const GradScreen({super.key});

  @override
  State<GradScreen> createState() => _GradScreenState();
}

class _GradScreenState extends State<GradScreen> {
  late GradProvider _gradProvider;
  SearchResult<Grad>? result;
  final TextEditingController _nazivGradaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gradProvider = context.read<GradProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    var data = await _gradProvider.get(filter: {'IsDrzavaIncluded': 'true'});
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Grad",
        child: Container(
          color: const Color.fromARGB(255, 204, 204, 204),
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
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(top: 20.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Naziv grada',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivGradaController,
            ),
            const SizedBox(height: 10),
           Column(
  children: [
    // Dugme za pretragu gradova
    Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
        child: ElevatedButton.icon(
          onPressed: () async {
            var filterParams = {'IsDrzavaIncluded': 'true'};

            if (_nazivGradaController.text.isNotEmpty) {
              filterParams['nazivGrada'] = _nazivGradaController.text;
            }

            var data = await _gradProvider.get(filter: filterParams);

            if (!mounted) return;

            setState(() {
              result = data;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10), // Povećava visinu dugmeta
          ),
          icon: const Icon(Icons.search, color: Colors.white),
          label: const Text(
            "Pretraži",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Veličina teksta
            ),
          ),
        ),
      ),
    ),
    
    // Dugme za dodavanje gradova (samo za Admin korisnike)
    if (context.read<UserProvider>().role == "Admin")
      Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GradDetailsScreen(grad: null),
                ),
              );
              // Ponovno učitavanje podataka nakon dodavanja novog grada
              await _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Dodaj',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
  ],
)

          ],
        ),
      ),
    ),
  );
}
Widget _buildDataListView() {
  return Expanded( // Koristimo Expanded kako bi popunili preostali prostor
      child: SingleChildScrollView( // Omogućavamo skrolovanje za ceo sadržaj
        child: Container(
    width: MediaQuery.of(context).size.width, // Širina 100% ekrana
    margin: const EdgeInsets.only(top: 20.0), // Razmak od vrha
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
        scrollDirection: Axis.vertical, // Dodan vertikalni scroll
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 10, // Manji razmak između kolona
          columns: const [
            DataColumn(
              label: Text(
                'Naziv grada',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12, // Smanjen font za naslov kolone
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv drzave',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12, // Smanjen font za naslov kolone
                ),
              ),
            ),
          ],
          rows: (result?.result ?? []).map(
            (Grad e) => DataRow(
              onSelectChanged: (selected) async {
                if (selected == true) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GradDetailsScreen(grad: e),
                    ),
                  );
                  await _loadData();
                }
              },
              cells: [
                DataCell(
                  Text(
                    e.nazivGrada ?? "",
                    style: const TextStyle(fontSize: 12), // Smanjen font za redove
                  ),
                ),
                DataCell(
                  Text(
                    e.drzava?.nazivDrzave ?? "",
                    style: const TextStyle(fontSize: 12), // Smanjen font za redove
                  ),
                ),
              ],
            ),
          ).toList(),
        ),
      ),
    ),
  )));
}

}
