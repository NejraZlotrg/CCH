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
    } else {
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
  return Card(
    margin: const EdgeInsets.all(16.0), // Margin oko kartice
    elevation: 4.0, // Senka za karticu
    child: SizedBox(
      height: 400, // Ograničenje visine za omogućavanje vertikalnog skrola
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Omogućava vertikalni skrol
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Omogućava horizontalni skrol
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
                  'Adresa', // Nova kolona za dugme
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Završena',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),

              DataColumn(
                label: Text(
                  'Akcija', // Nova kolona za dugme
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
  Text(e.adresa ?? 'Nema adrese'),  // Ako je adresa null, prikazuje se 'Nema adrese'
),
                          DataCell(
                            Icon(
                              e.zavrsenaNarudzba ? Icons.check_circle : Icons.cancel,
                              color: e.zavrsenaNarudzba ? Colors.green : Colors.red,
                            ),
                          ),
DataCell(
  ElevatedButton(
    onPressed: e.zavrsenaNarudzba
        ? null // Onemogući dugme ako je narudžba već završena
        : () async {
            try {
              // Pozovi funkciju potvrdiNarudzbu
              await _narudzbaProvider.potvrdiNarudzbu(e.narudzbaId);
              _loadData();              // Ako je uspješno završeno, možeš ažurirati status narudžbe ili UI
            } catch (error) {
              // Obradi grešku (prikazivanje obavještenja korisniku)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Greška pri završavanju narudžbe: $error')),
              );
            }
          },
    child: const Text('Označi kao završeno'),
  ),
)


                        ],
                      ),
                    )
                    .toList() ?? [],
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