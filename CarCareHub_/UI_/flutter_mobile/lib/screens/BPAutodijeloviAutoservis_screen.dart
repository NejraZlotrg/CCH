import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class BPAutodijeloviAutoservisScreen extends StatefulWidget {
  //final FirmaAutodijelova? firmaAutodijelova;

  const BPAutodijeloviAutoservisScreen({super.key});

  @override
  State<BPAutodijeloviAutoservisScreen> createState() =>
      _BPAutodijeloviAutoservisScreenState();
}

class _BPAutodijeloviAutoservisScreenState extends State<BPAutodijeloviAutoservisScreen> {
 
  SearchResult<BPAutodijeloviAutoservis>? result;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
 
    
    // Provjeri da li je firmaAutodijelova poslata i pozovi API
   
  }

  Future<void> _fetchData() async {
    var filterParams = {
      'IsAllIncluded': 'true', // Ovaj parametar ostaje
    };

   

    setState(() {
    //  result = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Baza autoservisa",
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
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });

              await _fetchData();
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
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Vertikalni pomak
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Naziv firme autodijelova',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv autoservisa',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                .map(
                  (BPAutodijeloviAutoservis e) => DataRow(
                    cells: [
                      DataCell(Text(e.autoservis?.naziv ?? "")),
                      DataCell(Text(e.firmaAutodijelova?.nazivFirme ?? "")),
                    ],
                  ),
                )
                .toList() ?? [],
        ),
      ),
    );
  }
}
