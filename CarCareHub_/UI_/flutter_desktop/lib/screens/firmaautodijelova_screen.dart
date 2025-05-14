// ignore_for_file: avoid_print

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
      data = await _firmaAutodijelovaProvider
          .getAdmin(filter: {'IsAllncluded': 'true'});
    } else {
      data = await _firmaAutodijelovaProvider
          .get(filter: {'IsAllncluded': 'true'});
    }
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  void _onSearchPressed() async {
    var filterParams = {
      'IsAllIncluded': 'true',
    };

    if (_nazivFirmeController.text.isNotEmpty) {
      filterParams['NazivFirme'] = _nazivFirmeController.text;
    }

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
      title: "Firme autodijelova",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204),
        child: Column(
          children: [
            _buildSearch(),
            _buildCompanyCards(),
          ],
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
                onPressed: _onSearchPressed,
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
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const FirmaAutodijelovaDetailScreen(
                                firmaAutodijelova: null),
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

  Widget _buildCompanyCards() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: result?.result.isEmpty ?? true
            ? const Center(child: Text("Nema rezultata"))
            : ListView.builder(
                itemCount: result?.result.length ?? 0,
                itemBuilder: (context, index) {
                  final company = result!.result[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: company.vidljivo == false
                            ? Colors.red
                            : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FirmaAutodijelovaReadScreen(
                              firmaAutodijelova: company,
                            ),
                          ),
                        );
                        await _loadData();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 90,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.grey[200],
                                ),
                                child: company.slikaProfila != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: imageFromBase64String(
                                            company.slikaProfila!),
                                      )
                                    : const Icon(Icons.business,
                                        size: 30, color: Colors.grey),
                              ),
                              const SizedBox(width: 50),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company.nazivFirme ?? "Nepoznata firma",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: company.vidljivo == false
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (company.telefon != null &&
                                        company.telefon!.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          "Tel: ${company.telefon}",
                                          style: TextStyle(
                                            color: company.vidljivo == false
                                                ? Colors.red
                                                : Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${company.grad?.nazivGrada ?? "Nepoznat grad"}${company.adresa != null && company.adresa!.isNotEmpty ? ", ${company.adresa!}" : ""}',
                                      style: TextStyle(
                                        color: company.vidljivo == false
                                            ? Colors.red
                                            : Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (company.vidljivo == false &&
                                  context.read<UserProvider>().role == "Admin")
                                const Icon(Icons.visibility_off,
                                    size: 20, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
