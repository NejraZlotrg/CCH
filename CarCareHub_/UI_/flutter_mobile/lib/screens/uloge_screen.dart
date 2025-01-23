import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/screens/uloge_details_screen.dart';
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
    _fetchInitialData();
  }
   Future<void> _fetchInitialData() async {
    try {
      var data = await _ulogeProvider.get(filter: {
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
      title: "Uloge",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Naziv uloge',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivUlogeController,
            ),
            const SizedBox(height: 10),
          Column(
  children: [
    // Dugme za pretragu
            // Dugmad za pretragu
Align(
  alignment: Alignment.centerRight,
  child: SizedBox(
    width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
    child: ElevatedButton.icon(
      onPressed: _onSearchPressed,
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
if (context.read<UserProvider>().role == "Admin")
      Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>  UlogeDetailsScreen(uloge: null),
                ),
              );
              await _fetchInitialData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Crvena boja za dugme
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Dodaj', style: TextStyle(color: Colors.white)),
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

 
  Future<void> _onSearchPressed() async {
    var filterParams = {'IsAllIncluded': 'true'};
    if (_nazivUlogeController.text.isNotEmpty) {
      filterParams['nazivUloge'] = _nazivUlogeController.text;
    }
 
    var data = await _ulogeProvider.get(filter: filterParams);
 
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
          child: DataTable(
                      showCheckboxColumn: false,

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
                        onSelectChanged: (selected) async  {
                          if (selected == true) {
                           await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    UlogeDetailsScreen(uloge: e),
                              ),
                            );
                    await _fetchInitialData();

                  }
                },
                cells: [
                  DataCell(Text(e.nazivUloge.toString())),
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

 