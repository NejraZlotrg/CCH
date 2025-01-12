import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/usluge.dart'; // Importuj svoju klasu za uslugu
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
 
import 'package:flutter_mobile/screens/usluge_details_screen.dart'; // Importuj ekran za detalje usluge
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
 
class UslugeScreen extends StatefulWidget {
  const UslugeScreen({super.key});
 
  @override
  State<UslugeScreen> createState() => _UslugeScreenState();
}
 
class _UslugeScreenState extends State<UslugeScreen> {
  late UslugeProvider _uslugaProvider;
  SearchResult<Usluge>? result;
  final TextEditingController _nazivUslugeController = TextEditingController();
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uslugaProvider = context.read<UslugeProvider>();
     _loadData();
  }
 Future<void> _loadData() async {
  var data = await _uslugaProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Usluge",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
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
                    labelText: 'Naziv usluge',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _nazivUslugeController,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _onSearchPressed,
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
                    await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    UslugeDetailsScreen(usluge: null),
                              ),
                            );
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
 
  Future<void> _onSearchPressed() async {
    var filterParams = {'IsAllIncluded': 'true'};
    if (_nazivUslugeController.text.isNotEmpty) {
      filterParams['nazivUsluge'] = _nazivUslugeController.text;
    }
 
    var data = await _uslugaProvider.get(filter: filterParams);
 
    if (!mounted) return;
 
    setState(() {
      result = data;
    });
  }
 
  Widget _buildDataListView() {
    return Expanded( // Koristimo Expanded kako bi popunili preostali prostor
      child: SingleChildScrollView( // Omogućavamo skrolovanje za ceo sadržaj
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 20.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.0),
              side: const BorderSide(color: Colors.black, width: 1.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Vertikalno skrolovanje
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'Naziv usluge',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Cijena',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                rows: result?.result
                    .map(
                      (Usluge e) => DataRow(
                        onSelectChanged: (selected) async  {
                          if (selected == true) {
                           await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    UslugeDetailsScreen(usluge: e),
                              ),
                            );
                    await _loadData();


                  }
                },
                cells: [
                  DataCell(Text(e.nazivUsluge.toString())),
                  DataCell(Text(e.cijena.toString())),

                ],
             
                      ),
                    )
                    .toList() ??
                [],
          ),
        ),
      ),
    )));
  }
}