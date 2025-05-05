import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
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
    _loadData();
    _fetchInitialData(); // Initial fetch
  }

  Future<void> _loadData() async {
    var data = await _drzaveProvider.get(filter: {'IsAllncluded': 'true'});
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      SearchResult<Drzave> data;
       if (context.read<UserProvider>().role == "Admin") {
         data = await _drzaveProvider.getAdmin(filter: {'IsAllncluded': 'true'});
       } else {
         data = await _drzaveProvider.get(filter: {'IsAllncluded': 'true'});
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
      title: "Drzava",
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
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Naziv države',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivDrzaveController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      var filterParams = {'IsAllncluded': 'true'};

                      if (_nazivDrzaveController.text.isNotEmpty) {
                        filterParams['nazivDrzave'] =
                            _nazivDrzaveController.text;
                      }

                      try {
                        SearchResult<Drzave> data;
                        if (context.read<UserProvider>().role == "Admin") {
                          data = await _drzaveProvider.getAdmin(
                              filter: filterParams);
                        } else {
                          data = await _drzaveProvider.get(filter: filterParams);
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
                    icon: const Icon(Icons.search),
                    label: const Text('Pretraga'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                if (context.read<UserProvider>().role == "Admin") ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                DrzaveDetailsScreen(drzava: null),
                          ),
                        );
                        await _loadData();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Dodaj'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ]
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
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
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
                      onSelectChanged: (selected) async {
                        if (selected == true) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DrzaveDetailsScreen(drzava: e),
                            ),
                          );
                          await _loadData();
                        }
                      },
                      cells: [
                        DataCell(
                          Text(
                            e.nazivDrzave ?? "",
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
