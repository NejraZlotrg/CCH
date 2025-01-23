import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/screens/godiste_details_screen.dart';
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
  final TextEditingController _nazivModelaController = TextEditingController();

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
      child: SingleChildScrollView( // Added scrolling to the entire screen
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
                labelText: 'Godiste:',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivModelaController,
            ),
            const SizedBox(height: 10),
       Column(
  children: [
    // Dugme za pretragu modela/godišta
    Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
        child: ElevatedButton.icon(
          onPressed: () async {
            var filterParams = {'IsAllIncluded': 'true'};

            if (_nazivModelaController.text.isNotEmpty) {
              filterParams['godiste_'] = _nazivModelaController.text;
            }

            var data = await _godisteProvider.get(filter: filterParams);

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
            "Pretraga",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Veličina teksta
            ),
          ),
        ),
      ),
    ),

    // Dugme za dodavanje modela/godišta (samo za Admin korisnike)
    if (context.read<UserProvider>().role == "Admin")
      Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: double.infinity, // Postavlja dugme da zauzme cijelu širinu reda
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GodisteDetailsScreen(godiste: null),
                ),
              );
              // Ponovno učitavanje podataka nakon dodavanja novog modela
              await _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Crvena boja za dugme
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
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: const EdgeInsets.only(
        top: 20.0,
      ),
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
          scrollDirection: Axis.vertical, // Ensure vertical scroll
          child: DataTable(
                      showCheckboxColumn: false,

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
                        onSelectChanged: (selected) async  {
                          if (selected == true) {
                           await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    GodisteDetailsScreen(godiste: e),
                              ),
                            );
                    await _loadData();

                  }
                },
                cells: [
                  DataCell(Text(e.godiste_.toString())),
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
