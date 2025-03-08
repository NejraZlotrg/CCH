import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class NarudzbaScreen extends StatefulWidget {
  const NarudzbaScreen({super.key});

  @override
  State<NarudzbaScreen> createState() => _NarudzbaScreenState();
}

class _NarudzbaScreenState extends State<NarudzbaScreen> {
  late NarudzbaProvider _narudzbaProvider;
  SearchResult<Narudzba>? result;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      var data = await _narudzbaProvider.get();
      setState(() {
        result = data;
        isLoading = false;
      });
    } catch (e) {
      print('Greška prilikom učitavanja narudžbi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Narudzbe",
        child: Container(
          color: const Color.fromARGB(255, 204, 204, 204),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                _buildDataListView(),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildDataListView() {
    return Card(
      margin: const EdgeInsets.all(16.0), // Add margin around the card
      elevation: 4.0, // Add shadow to the card
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(
              label: Text(
                'Datum narudžbe',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Datum isporuke',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Ukupna cijena narudžbe',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Završena',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (Narudzba e) => DataRow(
                      cells: [
                        DataCell(Text(e.datumNarudzbe != null
                            ? formatDate(e.datumNarudzbe!)
                            : 'N/A')),
                        DataCell(Text(e.datumIsporuke != null
                            ? formatDate(e.datumIsporuke!)
                            : 'N/A')),
                        DataCell(Text(e.ukupnaCijenaNarudzbe != null
                            ? '${e.ukupnaCijenaNarudzbe!.toStringAsFixed(2)} KM'
                            : 'N/A')),
                        DataCell(
                          Icon(
                            e.zavrsenaNarudzba ? Icons.check_circle : Icons.cancel,
                            color: e.zavrsenaNarudzba ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList() ??
              [],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}