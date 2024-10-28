import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/screens/zaposlenik_details_screen.dart';

import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ZaposlenikScreen extends StatefulWidget {
  const ZaposlenikScreen({super.key});

  @override
  State<ZaposlenikScreen> createState() => _ZaposlenikScreenState();
}

class _ZaposlenikScreenState extends State<ZaposlenikScreen> {
  late ZaposlenikProvider _zaposlenikProvider;
  SearchResult<Zaposlenik>? result;
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Zaposlenici",
      child: Column(
        children: [
          _buildSearch(),
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
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Ime',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _imeController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Prezime",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _prezimeController,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              var data = await _zaposlenikProvider.get(filter: {
                'ime': _imeController.text,
                'prezime': _prezimeController.text
              });

              setState(() {
                result = data;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, color: Colors.white),
                SizedBox(width: 8.0),
                Text('Pretraga', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ZaposlenikDetailsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8.0),
                Text('Dodaj', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          dataRowHeight: 70,
          headingRowHeight: 70,
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ime', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Prezime', style: TextStyle(fontWeight: FontWeight.bold))),
         //  DataColumn(label: Text('Grad', style: TextStyle(fontWeight: FontWeight.bold))),
           // DataColumn(label: Text('Uloga', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: result?.result.map((Zaposlenik e) {
            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ZaposlenikDetailsScreen(),
                    ),
                  );
                }
              },
              cells: [
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.zaposlenikId?.toString() ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.ime ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.prezime ?? ""),
                )),
              /* DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.grad ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.uloga ?? ""),
                )),*/
              ],
            );
          }).toList() ?? [],
        ),
      ),
    );
  }
}
