import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/screens/firmaautodijelova_details_screen.dart';
import 'package:flutter_mobile/screens/firmaautodijelova_read_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class FirmaAutodijelovaScreen extends StatefulWidget {
  const FirmaAutodijelovaScreen({super.key});

  @override
  State<FirmaAutodijelovaScreen> createState() =>
      _FirmaAutodijelovaScreenState();
}
class _FirmaAutodijelovaScreenState extends State<FirmaAutodijelovaScreen> {
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  SearchResult<FirmaAutodijelova>? result;
  final TextEditingController _nazivFirmeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    SearchResult<FirmaAutodijelova> data;
     if (context.read<UserProvider>().role == "Admin") {
       data = await _firmaAutodijelovaProvider.getAdmin(filter: {'IsAllncluded': 'true'});
     } else {
       data = await _firmaAutodijelovaProvider.get(filter: {'IsAllncluded': 'true'});
     }
    if (mounted) {
      setState(() {
        result = data;
        
 
      });
    }
  }

  
void _onSearchPressed() async {
  var filterParams = {
    'IsAllIncluded': 'true', // Ovaj parametar ostaje
  };

  // Dodavanje filtera samo ako je naziv unesen
  if (_nazivFirmeController.text.isNotEmpty) {
    filterParams['NazivFirme'] = _nazivFirmeController.text;
  }

  print("Filter Params: $filterParams"); // Debugging log

 try {
                    SearchResult<FirmaAutodijelova> data;
                      if (context.read<UserProvider>().role == "Admin") {
                        data = await _firmaAutodijelovaProvider.getAdmin(filter: filterParams);
                      } else {
                        data = await _firmaAutodijelovaProvider.get(filter: filterParams);
                      }
                    if (mounted) {
                      setState(() {
                        result = data;
                      });
                    }
                  } catch (e) {
                    print("Error fetching filtered data: $e");
                  }

}


  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "FirmaAutodijelova",
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
                  controller: _nazivFirmeController,
                  decoration: const InputDecoration(
                    labelText: 'Naziv firme',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _onSearchPressed, // Koristi novu funkciju
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 32, 17),
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
                                    FirmaAutodijelovaDetailScreen(firmaAutodijelova: null),
                              ),
                            );
                    await _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 249, 29, 13),
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
              const SizedBox(width: 10),
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
        scrollDirection: Axis.vertical,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('nazivFirme', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn(label: Text('adresa', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn(label: Text('grad', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn(label: Text('SlikaProfila', style: TextStyle(fontStyle: FontStyle.italic))),
          ],
          rows: result?.result
                  .map(
                    (FirmaAutodijelova e) => DataRow(
                      onSelectChanged: (selected) async {
                        if (selected == true) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FirmaAutodijelovaReadScreen(
                                firmaAutodijelova: e,
                              ),
                            ),
                          );
                          await _loadData();
                        }
                      },
                      cells: [
                        DataCell(Text(
                          e.nazivFirme ?? "",
                          style: TextStyle(color: e.vidljivo == false ? Colors.red : Colors.black),
                        )),
                        DataCell(Text(
                          e.adresa ?? "",
                          style: TextStyle(color: e.vidljivo == false ? Colors.red : Colors.black),
                        )),
                        DataCell(Text(
                          e.grad?.nazivGrada ?? "",
                          style: TextStyle(color: e.vidljivo == false ? Colors.red : Colors.black),
                        )),
                        DataCell(
                          e.slikaProfila != null
                              ? SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: imageFromBase64String(e.slikaProfila!),
                                )
                              : Text(
                                  "",
                                  style: TextStyle(color: e.vidljivo == false ? Colors.red : Colors.black),
                                ),
                        ),
                      ],
                    ),
                  )
                  .toList() ?? [],
        ),
      ),
    ),))
  );
}

}