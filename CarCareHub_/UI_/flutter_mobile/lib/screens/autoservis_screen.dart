import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/screens/autoservis_details_screen.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AutoservisScreen extends StatefulWidget {
  const AutoservisScreen({super.key});

  @override
  State<AutoservisScreen> createState() => _AutoservisScreenState();
}

class _AutoservisScreenState extends State<AutoservisScreen> {
  late AutoservisProvider _autoservisProvider;
  SearchResult<Autoservis>? result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoservisProvider = context.read<AutoservisProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Autoservis",
      child: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildDataTable()), // Omogućavanje skrolanja unutar tabele
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(  // Polja za pretragu postavljena jedno ispod drugog
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Naziv',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: "MBS",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: "JIB",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  print("Pretraga podataka");
                  var data = await _autoservisProvider.get(filter: {});
                  setState(() {
                    result = data;
                  });
                },
                child: const Row(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AutoservisDetailsScreen(autoservis: null),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8.0),
                    Text('Dodaj'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(  // Omogućavanje vodoravnog skrolanja
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Naziv')),
          DataColumn(label: Text('Adresa')),
          DataColumn(label: Text('Vlasnik')),
          DataColumn(label: Text('Telefon')),
          DataColumn(label: Text('Grad')),
          DataColumn(label: Text('Email')),
        ],
        rows: result?.result
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(Text(e.autoservisId?.toString() ?? "")),
                  DataCell(Text(e.naziv ?? "")),
                  DataCell(Text(e.adresa ?? "")),
                  DataCell(Text(e.vlasnikFirme ?? "")),
                  DataCell(Text(e.telefon ?? "")),
                  DataCell(Text(e.gradId.toString())),
                  DataCell(Text(e.email ?? "")),
                ],
              ),
            )
            .toList() ??
            [],
      ),
    );
  }
}
