import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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
    // Ako je firmaAutodijelova prosleđena, pozivamo pretragu odmah prilikom učitavanja ekrana
    if (widget.firmaAutodijelova != null && isLoading) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    var filterParams = {
      'IsAllIncluded': 'true',
      'AutodijeloviID': widget.firmaAutodijelova?.firmaAutodijelovaID,
    };

    print("Filter params: $filterParams");

    try {
      if (context.read<UserProvider>().role == "Admin") {
        print("Pozivam getAdmin metodu...");
        result = await _provider.getAdmin(filter: filterParams);
      } else {
        print("Pozivam get metodu...");
        result = await _provider.get(filter: filterParams);
      }

      print("Podaci uspješno dohvaćeni: ${result?.result.length} zapisa");

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Greška pri dohvatanju podataka: $e");
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
          _buildSearch(),  // Ako želiš da zadržiš dugme za pretragu, zadrži ovo
          _buildDataListView(),
        ],
      ),
      ),
    );
  }

  Widget _buildSearch() {
  return Padding(
    padding: const EdgeInsets.only( left: 50, right: 50, top: 20, bottom: 20), // 50px sa obe strane
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Centriraj vertikalno
      children: [

        const SizedBox(height: 10), // Razmak između dugmadi
        ElevatedButton(
          onPressed: () { 
            _showAutoservisDialog(context); // Open the dialog
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            minimumSize: const Size(double.infinity, 50), // Puna širina
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
    child: ListView.builder(
      itemCount: result?.result.length ?? 0,
      itemBuilder: (context, index) {
        final e = result!.result[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Firma autodijelova:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  e.firmaAutodijelova?.nazivFirme ?? "Nepoznato",
                  style: TextStyle(
                    color: (e.firmaAutodijelova?.vidljivo == null || e.vidljivo == false)
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Autoservis:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  e.autoservis?.naziv ?? "Nepoznato",
                  style: TextStyle(
                    color: (e.autoservis?.vidljivo == null || e.vidljivo == false)
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
                      _deleteBPAutodijeloviAutoservis(e.bpAutodijeloviAutoservisId);
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
        await _provider.delete(id); // Pozovi delete metodu iz providera
        _fetchData(); // Osvježi podatke nakon brisanja
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zapis uspješno obrisan')),
        );
      } catch (e) {
        print("Greška pri brisanju: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri brisanju: $e')),
        );
      }
    }
  }
}