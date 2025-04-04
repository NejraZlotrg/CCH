import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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
     var korisnik=context.read<UserProvider>().userId;
         SearchResult<Narudzba> data;
    if (context.read<UserProvider>().role == "Admin") {
      data = await _narudzbaProvider.getAdmin(filter: {'IsDrzavaIncluded': 'true'});
    } 
    else if (context.read<UserProvider>().role == "Firma autodijelova") {
      var ii=context.read<UserProvider>().userId;
      data = await _narudzbaProvider.getNarudzbeZaFirmu(ii);
      print('user id-------------------------$ii');
    }
    else {
      data = await _narudzbaProvider.getNarudzbePoUseru(korisnik); //ERROR MOra ovjde biti drugi tip search result a ne list anrudzba
    }
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
  final userRole = context.read<UserProvider>().role;

  return Card(
    margin: const EdgeInsets.all(16.0),
    elevation: 4.0,
    child: SizedBox(
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: [
              const DataColumn(
                label: Text(
                  'Datum narudžbe',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Datum isporuke',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Ukupna cijena narudžbe',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Adresa',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Završena',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              if (userRole == "Firma autodijelova")
                const DataColumn(
                  label: Text(
                    'Akcija',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
            ],
            rows: result?.result.map((Narudzba e) {
              return DataRow(
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
                  DataCell(Text(e.adresa ?? 'Nema adrese')),
                  DataCell(Icon(
                    e.zavrsenaNarudzba ? Icons.check_circle : Icons.cancel,
                    color: e.zavrsenaNarudzba ? Colors.green : Colors.red,
                  )),
                  if (userRole == "Firma autodijelova")
                    DataCell(
                      ElevatedButton(
                        onPressed: e.zavrsenaNarudzba
                            ? null
                            : () async {
                                try {
                                  await _narudzbaProvider
                                      .potvrdiNarudzbu(e.narudzbaId);
                                  _loadData();
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Greška pri završavanju narudžbe: $error')),
                                  );
                                }
                              },
                        child: const Text('Označi kao završeno'),
                      ),
                    ),
                ],
              );
            }).toList() ?? [],
          ),
        ),
      ),
    ),
  );
}


  String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
