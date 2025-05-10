// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/screens/narudzba_stavka_screen.dart';
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
      var korisnik = context.read<UserProvider>().userId;
      SearchResult<Narudzba> data;

      if (context.read<UserProvider>().role == "Admin") {
        data = await _narudzbaProvider.getAdmin(filter: {'IsDrzavaIncluded': 'true'});
      } else if (context.read<UserProvider>().role == "Firma autodijelova") {
        var ii = context.read<UserProvider>().userId;
        data = await _narudzbaProvider.getNarudzbeZaFirmu(ii);
      } else {
        data = await _narudzbaProvider.getNarudzbePoUseru(korisnik);
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
    title: "Narudžbe",
    child: Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      color: const Color.fromARGB(255, 204, 204, 204),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildMobileListView(),
                ],
              ),
            ),
    ),
  );
}


  Widget _buildMobileListView() {
    final userRole = context.read<UserProvider>().role;
    final isFirma = userRole == "Firma autodijelova";

    if (result?.result.isEmpty ?? true) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Nema narudžbi za prikaz"),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: result?.result.length ?? 0,
      itemBuilder: (context, index) {
        final e = result!.result[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NarudzbaStavkaScreen(narudzbaId: e.narudzbaId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Datum narudžbe:", formatDate(e.datumNarudzbe!)),
                  const SizedBox(height: 8),
                  _buildInfoRow("Datum isporuke:", 
                      e.datumIsporuke != null ? formatDate(e.datumIsporuke!) : 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow("Ukupna cijena:", 
                      '${e.ukupnaCijenaNarudzbe?.toStringAsFixed(2) ?? 'N/A'} KM'),
                  const SizedBox(height: 8),
                  _buildInfoRow("Adresa:", e.adresa ?? 'Nema adrese'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(
                        e.zavrsenaNarudzba ? Icons.check_circle : Icons.cancel,
                        color: e.zavrsenaNarudzba ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(e.zavrsenaNarudzba ? "Završena" : "U toku"),
                    ],
                  ),
                  if (isFirma && !e.zavrsenaNarudzba)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
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
                          child: const Text(
                            'Završi narudžbu',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }
}