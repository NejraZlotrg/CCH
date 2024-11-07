import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "FirmaAutodijelova",
      child: Column(
        children: [
          _buildSearch(),
          _buildDataListView(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          ElevatedButton(
            onPressed: () async {
              print("podaci proceed");
              var filterParams = {
                'IsAllncluded': 'true', // Ovaj parametar ostaje
              };

 // Dodavanje filtera samo ako je naziv unesen
  if (_nazivFirmeController.text.isNotEmpty) {
    filterParams['nazivFirme'] = _nazivFirmeController.text;
  }

  var data = await _firmaAutodijelovaProvider.get(filter: filterParams);


              setState(() {
                result = data;
              });
            },
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
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const FirmaAutodijelovaDetailScreen(
                          firmaAutodijelova: null,
                        ) // poziv na drugi screen
                    ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8.0),
                Text('Dodaj'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
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
                          print('selected: ${e.firmaAutodijelovaID}');
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
                        DataCell(Text(e.firmaAutodijelovaID?.toString() ?? "")),
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
    );
  }
}
