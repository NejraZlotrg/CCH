import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/screens/drzave_details_screen.dart';
import 'package:flutter_mobile/screens/kategorija_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class KategorijaScreen extends StatefulWidget {
  const KategorijaScreen({super.key});

  @override
  State<KategorijaScreen> createState() => _KategorijaScreenState();
}

class _KategorijaScreenState extends State<KategorijaScreen> {
  late KategorijaProvider _kategorijaProvider;
  SearchResult<Kategorija>? result;
  final TextEditingController _nazivKategorijeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _loadData();
    _fetchInitialData(); // Initial fetch
  }

  Future<void> _loadData() async {
    var data = await _kategorijaProvider.get();
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      SearchResult<Kategorija> data;
       if (context.read<UserProvider>().role == "Admin") {
         data = await _kategorijaProvider.getAdmin();
       } else {
         data = await _kategorijaProvider.get();
       }
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
      title: "Kategorija",
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
          side: const BorderSide(color: Colors.black, width: 1.0),
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
                  controller: _nazivKategorijeController,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  var filterParams = {'IsAllncluded': 'true'};

                  if (_nazivKategorijeController.text.isNotEmpty) {
                    filterParams['nazivDrzave'] = _nazivKategorijeController.text;
                  }

                  try {
                    SearchResult<Kategorija> data;
                     if (context.read<UserProvider>().role == "Admin") {
                       data = await _kategorijaProvider.getAdmin(filter: filterParams);
                     } else {
                       data = await _kategorijaProvider.get(filter: filterParams);
                     }
                    if (mounted) {
                      setState(() {
                        result = data;
                      });
                    }
                  } catch (e) {
                    print("Error fetching filtered data: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => KategorijaDetailsScreen(kategorija: null),
                      ),
                    );
                    // Reload data after returning from DrzaveDetailsScreen
                    await _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8.0),
                      Text('Dodaj'),
                    ],
                  ),
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
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      child: SingleChildScrollView( // Dodajemo SingleChildScrollView za omogućavanje skrolovanja
        scrollDirection: Axis.vertical, // Postavljamo vertikalno skrolovanje
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(
              label: Text(
                'Naziv kategorije',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (Kategorija e) => DataRow(
                      onSelectChanged: (selected) async {
                        if (selected == true) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => KategorijaDetailsScreen(kategorija: e),
                            ),
                          );
                          await _loadData();
                        }
                      },
                      cells: [
                        DataCell(
                          Text(
                            e.nazivKategorije ?? "",
                            style: TextStyle(
                              color: e.vidljivo == false ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList() ??
              [],
        ),
      ),
    ),))
  );
}

}
