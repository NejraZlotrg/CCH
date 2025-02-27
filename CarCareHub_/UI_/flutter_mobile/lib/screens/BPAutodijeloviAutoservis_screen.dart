
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
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
        _buildSearch(), // Search bar at the top
        _buildDataListView(), // List of items below
      ],
    ),
  );
}

Widget _buildSearch() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pretraži...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              // Add search logic here if needed
            },
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            await _fetchData();
          },
          child: const Text('Pretraga'),
        ),
      ],
    ),
  );
}

Widget _buildDataListView() {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (result == null || result!.isEmpty) {
    return const Center(
      child: Text("Nema podataka za prikaz."),
    );
  }

  return Expanded(
    child: ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: result!.length,
      itemBuilder: (context, index) {
        final item = result![index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          child: ListTile(
            title: Text(
              item.autoservis?.naziv ?? "Nema naziva autoservisa",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item.firmaAutodijelova?.nazivFirme ?? "Nema naziva firme autodijelova",
            ),
          ),
        );
      },
    ),
  );
}
}
