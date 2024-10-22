import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/narudzba_stavka_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class NarudzbaStavkaScreen extends StatefulWidget {
  const NarudzbaStavkaScreen({super.key});

  @override
  State<NarudzbaStavkaScreen> createState() => _NarudzbaStavkaScreenState();
}

class _NarudzbaStavkaScreenState extends State<NarudzbaStavkaScreen> {
  late NarudzbaStavkeProvider _narudzbaStavkaProvider;
  SearchResult<NarudzbaStavke>? result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaStavkaProvider = context.read<NarudzbaStavkeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Narudzba stavke",
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
              print("Pokretanje pretrage:");

              var filterParams = {
                'IsAllncluded': 'true', // Parametar za filtriranje
              };

              var data = await _narudzbaStavkaProvider.get(filter: filterParams);
              print(data);  // Debugging output


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
              // Navigacija ka ekranu za dodavanje
            },
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
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Vertikalni pomak
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Proizvod',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Kolicina',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Narudzba ID',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Ukupna cijena proizvoda',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (NarudzbaStavke e) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          print('Selected: ${e.proizvodId}');
                        }
                      },
                      cells: [
                        DataCell(Text(e.proizvod?.naziv ?? 'N/A')),
                        DataCell(Text(e.kolicina.toString())),
                        DataCell(Text(e.narudzba?.narudzbaId.toString() ?? 'N/A')),
                        DataCell(Text(e.ukupnaCijenaProizvoda.toString())),
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
