import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductProvider _productProvider;
  SearchResult<Product>? result;
  final TextEditingController _nazivController = new TextEditingController();


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
                          labelText: 'Korisničko ime',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,

                      
                        ),
                        controller:_nazivController,
                      ),
          ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Naziv proizvoda",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Lokacija",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "JIB ili MB",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  print("podaci proceed");
                  var data = await _productProvider.get(filter: {
                    'naziv': _nazivController.text,
                  });
            
                  setState(() {
                    result = data;
                  });
                  if (data.result.isNotEmpty) {
                    print("data: ${data.result[0].naziv}");
                  } else {
                    print("No data found");
                  }
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
            ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            const DataColumn(
              label: Text(
                'ID',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const DataColumn(
              label: Text(
                'Sifra',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const DataColumn(
              label: Text(
                'Naziv',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result.map((Product e) {
            return DataRow(
              cells: [
                DataCell(Text(e.proizvodId?.toString() ?? "")),
                DataCell(Text(e.sifra ?? "")),
                DataCell(Text(e.naziv ?? "")),
              ],
            );
          }).toList() ?? [],
        ),
      ),
    );
  }
}
