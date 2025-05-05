// ignore_for_file: use_build_context_synchronously, empty_catches

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/bpautodijelovi_autoservis_provider.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class BPAutodijeloviAutoservisScreen extends StatefulWidget {
  final FirmaAutodijelova? firmaAutodijelova;

  const BPAutodijeloviAutoservisScreen({super.key, this.firmaAutodijelova});

  @override
  State<BPAutodijeloviAutoservisScreen> createState() =>
      _BPAutodijeloviAutoservisScreenState();
}

class _BPAutodijeloviAutoservisScreenState
    extends State<BPAutodijeloviAutoservisScreen> {
  SearchResult<BPAutodijeloviAutoservis>? result;
  late BPAutodijeloviAutoservisProvider _provider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _provider = context.read<BPAutodijeloviAutoservisProvider>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.firmaAutodijelova != null && isLoading) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    var filterParams = {
      'IsAllIncluded': 'true',
      'AutodijeloviID': widget.firmaAutodijelova?.firmaAutodijelovaID,
    };

    try {
      if (context.read<UserProvider>().role == "Admin") {
        result = await _provider.getAdmin(filter: filterParams);
      } else {
        result = await _provider.get(filter: filterParams);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri pretrazi: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Baza autoservisa",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204),
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
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _showAutoservisDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8.0),
                Text('Dodaj Autoservis', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAutoservisDialog(BuildContext context) async {
    var autoservisiResult = await context.read<AutoservisProvider>().get();

    if (!mounted) return;

    Autoservis? selectedAutoservis;
    String searchQuery = "";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Autoservis> filteredAutoservisi = autoservisiResult.result
                .where((autoservis) =>
                    autoservis.naziv
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false)
                .toList();

            return AlertDialog(
              title: const Text('Izaberi Autoservis'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Pretraži po nazivu',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Naziv Autoservisa')),
                      ],
                      rows: filteredAutoservisi
                          .map(
                            (Autoservis e) => DataRow(
                              cells: [
                                DataCell(
                                  Text(e.naziv ?? ""),
                                  onTap: () {
                                    selectedAutoservis = e;
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Otkaži'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedAutoservis != null) {
      await _insertBPAutodijeloviAutoservis(selectedAutoservis!.autoservisId!);
    }
  }

  Future<void> _insertBPAutodijeloviAutoservis(int autoservisId) async {
    if (widget.firmaAutodijelova == null) {
      return;
    }

    var request = {
      "firmaAutodijelovaId": widget.firmaAutodijelova!.firmaAutodijelovaID,
      "autoservisId": autoservisId,
    };

    try {
      await context.read<BPAutodijeloviAutoservisProvider>().insert(request);
      _fetchData();
    } catch (e) {}
  }

  Widget _buildDataListView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: ListView.builder(
        itemCount: result?.result.length ?? 0,
        itemBuilder: (context, index) {
          final e = result!.result[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Firma autodijelova:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    e.firmaAutodijelova?.nazivFirme ?? "Nepoznato",
                    style: TextStyle(
                      color: (e.firmaAutodijelova?.vidljivo == null ||
                              e.vidljivo == false)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Autoservis:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    e.autoservis?.naziv ?? "Nepoznato",
                    style: TextStyle(
                      color: (e.autoservis?.vidljivo == null ||
                              e.vidljivo == false)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteBPAutodijeloviAutoservis(
                            e.bpAutodijeloviAutoservisId);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteBPAutodijeloviAutoservis(int? id) async {
    if (id != null) {
      try {
        await _provider.delete(id);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zapis uspješno obrisan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri brisanju: $e')),
        );
      }
    }
  }
}
