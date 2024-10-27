import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductProvider _productProvider;
  SearchResult<Product>? result;
  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Proizvodi",
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
                labelText: 'Naziv proizvoda',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Model",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _modelController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "JIB ili MB",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              var data = await _productProvider.get(filter: {
                'naziv': _nazivController.text,
                'model': _modelController.text
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
                  builder: (context) => ProductDetailScreen(product: null),
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
          dataRowHeight: 70, // Povećaj visinu reda podataka
          headingRowHeight: 70, // Povećaj visinu reda zaglavlja
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Šifra', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Naziv', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Slika', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Cijena', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: result?.result.map((Product e) {
            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: e),
                    ),
                  );
                }
              },
              cells: [
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0), // Dodaj padding za razmak
                  child: Text(e.proizvodId?.toString() ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.sifra ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.naziv ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: e.slika != null && e.slika!.isNotEmpty // Provjera da li slika postoji
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Zaobljen okvir
                            border: Border.all(color: Colors.grey), // Okvir oko slike
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10), // Zaobljenje unutar okvira
                            child: Image.memory(
                              base64Decode(e.slika!), // Dekodiraj Base64 string
                              fit: BoxFit.cover, // Prilagodi sliku da se uklopi u kontejner
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Center(child: Text("x")), // Prikaz rezervne slike
                        ),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${formatNumber(e.cijena)} KM", style: TextStyle(color: Colors.blueGrey)), // Dodaj "KM" oznaku
                )),
              ],
            );
          }).toList() ?? [],
        ),
      ),
    );
  }
}
