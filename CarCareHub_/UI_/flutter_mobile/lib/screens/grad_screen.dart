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
    SearchResult<Grad> data;
    if (context.read<UserProvider>().role == "Admin") {
      data = await _gradProvider.getAdmin(filter: {'IsDrzavaIncluded': 'true'});
    } else {
      data = await _gradProvider.get(filter: {'IsDrzavaIncluded': 'true'});
    }
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
    margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0), // Margina sa svih strana
    child: Card(
      elevation: 4.0, // Dodaje malo sjene za karticu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Zaobljeni uglovi kartice
        side: const BorderSide(
          color: Colors.black, // Crni okvir
          width: 1.0, // Debljina okvira (1px)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Unutrašnji razmak
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Red za TextField
            TextField(
              controller: _nazivGradaController,
              decoration: const InputDecoration(
                labelText: 'Naziv grada',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12.0), // Razmak između inputa i dugmadi
            // Red za dugmadi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      var filterParams = {
                        'IsDrzavaIncluded': 'true', // Ovaj parametar ostaje
                      };

                      // Dodavanje filtera samo ako je naziv unesen
                      if (_nazivGradaController.text.isNotEmpty) {
                        filterParams['nazivGrada'] = _nazivGradaController.text;
                      }
                      SearchResult<Grad> data;
                      if (context.read<UserProvider>().role == "Admin") {
                        data = await _gradProvider.getAdmin(filter: filterParams);
                      } else {
                        data = await _gradProvider.get(filter: filterParams);
                      }
                      if (!mounted) return; // Provera da li je widget još uvek u montaži

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
                ),
                const SizedBox(width: 10), // Razmak između dugmadi
                if (context.read<UserProvider>().role == "Admin")
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GradDetailsScreen(grad: null),
                          ),
                        );
                        await _loadData();
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
                  ),
              ],
            ),
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
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(
              label: Text(
                'Naziv grada',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv drzave',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: (result?.result ?? []).map(
            (Grad e) {
              bool isRed = (e.vidljivo ?? true) == false;

              return DataRow(
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
                      style: TextStyle(
                        color: isRed ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      e.drzava?.nazivDrzave ?? "",
                      style: TextStyle(
                        color: isRed ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    ),))
  );
}
}
