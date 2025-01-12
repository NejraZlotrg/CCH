import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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
      var data = await _drzaveProvider.get(filter: {'IsAllncluded': 'true'});
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
      child: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 204, 204, 204),
          child: Column(
            children: [
              _buildSearch(),
              _buildDataListView(),
            ],
          ),
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
                  controller: _nazivDrzaveController,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  var filterParams = {'IsAllncluded': 'true'};

                  if (_nazivDrzaveController.text.isNotEmpty) {
                    filterParams['nazivDrzave'] = _nazivDrzaveController.text;
                  }

                  try {
                    var data = await _drzaveProvider.get(filter: filterParams);
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
                        builder: (context) => DrzaveDetailsScreen(drzava: null),
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
                                builder: (context) =>
                                    DrzaveDetailsScreen(drzava: e),
                              ),
                            );
                            // Reload data after selecting a row
                            await _loadData();
                          }
                        },
                        cells: [
                          DataCell(Text(e.nazivDrzave ?? "")),
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
