import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/screens/BPAutodijeloviAutoservis_screen.dart';
import 'package:flutter_mobile/screens/firmaautodijelova_details_screen.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
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
  var data = await _firmaAutodijelovaProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
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
                  labelText: 'Naziv firme',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: _nazivFirmeController,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                var filterParams = {
                  'IsAllncluded': 'true', // Ovaj parametar ostaje
                };

                // Dodavanje filtera samo ako je naziv unesen
                if (_nazivFirmeController.text.isNotEmpty) {
                  filterParams['nazivFirme'] = _nazivFirmeController.text;
                }

                var data =
                    await _firmaAutodijelovaProvider.get(filter: filterParams);

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
                    builder: (context) => const FirmaAutodijelovaDetailScreen(
                      firmaAutodijelova: null,
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
                'firmaAutodijelovaID',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'nazivFirme',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'adresa',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'grad',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'SlikaProfila',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (FirmaAutodijelova e) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    FirmaAutodijelovaDetailScreen(
                                      firmaAutodijelova: e,
                                    ) // poziv na drugi screen
                                ),
                          );
                        }
                      },
                      cells: [
                        DataCell(Text(e.firmaAutodijelovaID.toString())),
                        DataCell(Text(e.nazivFirme ?? "")),
                        DataCell(Text(e.adresa ?? "")),
                        DataCell(Text(e.grad?.nazivGrada ?? "")),
                        DataCell(e.slikaProfila != null
                            ? SizedBox(
                                width: 100,
                                height: 100,
                                child: imageFromBase64String(e.slikaProfila!),
                              )
                            : const Text("")),
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
