import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class BPAutodijeloviAutoservisScreen extends StatefulWidget {
  final FirmaAutodijelova? firmaAutodijelova; // Primanje objekta FirmaAutodijelova

  const BPAutodijeloviAutoservisScreen({super.key, this.firmaAutodijelova});

  @override
  State<BPAutodijeloviAutoservisScreen> createState() =>
      _BPAutodijeloviAutoservisScreenState();
}

class _BPAutodijeloviAutoservisScreenState extends State<BPAutodijeloviAutoservisScreen> {
  List<BPAutodijeloviAutoservis>? result;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ako je firmaAutodijelova prosleđena, pozivamo pretragu odmah prilikom učitavanja ekrana
    if (widget.firmaAutodijelova != null && isLoading) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    // Provera da li je firmaAutodijelovaID prisutan
    String firmaId = widget.firmaAutodijelova?.firmaAutodijelovaID.toString() ?? "";
    if (firmaId.isEmpty) {
      print("Firma ID nije prosleđen!");
      return;  // Ako nema ID-a, ne šaljemo upit
    }

    // Filtriranje sa prosleđenim ID-jem firme
    print("Filtriranje sa ID-jem firme: $firmaId");

    // Pozovi API koristeći filterParams
    var data = await context.read<BPAutodijeloviAutoservisProvider>().getById(widget.firmaAutodijelova!.firmaAutodijelovaID);

    if (!mounted) return; // Provera da li je widget još uvek montiran

    setState(() {
      result = data; // Postavi podatke
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Baza autoservisa",
      child: Column(
        children: [
          _buildSearch(),  // Ako želiš da zadržiš dugme za pretragu, zadrži ovo
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
        ElevatedButton(
          onPressed: () {
            _showAutoservisDialog(context); // Open the dialog
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8.0),
              Text('Dodaj Autoservis'),
            ],
          ),
        ),
      ],
    ),
  );
}
Future<void> _showAutoservisDialog(BuildContext context) async {
  // Fetch all Autoservis records
  var autoservisiResult = await context.read<AutoservisProvider>().get();

  if (!mounted) return;

  Autoservis? selectedAutoservis;
  String searchQuery = ""; // Track the search query

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Filter Autoservis records based on the search query
          List<Autoservis> filteredAutoservisi = autoservisiResult.result
              .where((autoservis) =>
                  autoservis.naziv?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
              .toList();

          return AlertDialog(
            title: const Text('Izaberi Autoservis'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Pretraži po nazivu',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value; // Update the search query
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // DataTable with filtered Autoservis records
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
                                  selectedAutoservis = e; // Set the selected Autoservis
                                  Navigator.of(context).pop(); // Close the dialog
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
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Otkaži'),
              ),
            ],
          );
        },
      );
    },
  );

  // If an Autoservis is selected, call the insert method
  if (selectedAutoservis != null) {
    await _insertBPAutodijeloviAutoservis(selectedAutoservis!.autoservisId!);
  }
}
Future<void> _insertBPAutodijeloviAutoservis(int autoservisId) async {
  // Ensure firmaAutodijelovaId is available
  if (widget.firmaAutodijelova == null) {
    print("FirmaAutodijelova ID nije dostupan!");
    return;
  }

  // Prepare the request body
  var request = {
    "firmaAutodijelovaId": widget.firmaAutodijelova!.firmaAutodijelovaID,
    "autoservisId": autoservisId,
  };

  // Call the insert method from the provider
  try {
    await context.read<BPAutodijeloviAutoservisProvider>().insert(request);
    _fetchData(); // Refresh the data after insertion
  } catch (e) {
    print("Greška pri dodavanju: $e");
  }
}

  Widget _buildDataListView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
          rows: result?.toList()
                .map(
                  (BPAutodijeloviAutoservis e) => DataRow(
                    cells: [
                      DataCell(
                        Text(
                          e.autoservis?.naziv ?? "",
                          style: TextStyle(
                            color: e.autoservis?.vidljivo == false 
                                ? Colors.red 
                                : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          e.firmaAutodijelova?.nazivFirme ?? "",
                          style: TextStyle(
                            color: e.firmaAutodijelova?.vidljivo == false 
                                ? Colors.red 
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList() ?? [],
        ),
      ),
    );
  }

}