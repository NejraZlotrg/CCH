
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
        ],
      ),
    );
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
)
;
  }
}
