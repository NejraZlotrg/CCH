import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
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
  final TextEditingController _nazivController = TextEditingController();

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
              decoration: const InputDecoration(
                labelText: 'Korisničko ime',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivController,
            ),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Naziv proizvoda",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Lokacija",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
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
            onPressed: () async {

                     Navigator.of(context).push(
                     MaterialPageRoute(builder: (context)=> ProductDetailScreen(product: null,) // poziv na drugi screen
                     ), );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8.0),
                Text('Dodaj'),
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
          columns: const [
            DataColumn(
              label: Text(
                'ID',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Šifra',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Slika',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Cijena',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (Product e) => DataRow(
                      onSelectChanged: (selected) {
                        if(selected == true) {
                          print('selected: ${e.proizvodId}');
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=> ProductDetailScreen(product: e,) // poziv na drugi screen
                          ), );
                        }

                      },
                      cells: [
                        DataCell(Text(e.proizvodId?.toString() ?? "")),
                        DataCell(Text(e.sifra ?? "")),
                        DataCell(Text(e.naziv ?? "")),
                        DataCell(e.slika != null
                            ? Container(
                                width: 100,
                                height: 100,
                                child: imageFromBase64String(e.slika!),
                              )
                            : const Text("")),
                        DataCell(Text(formatNumber(e.cijena))),
                      ],
                    ),
                  )
                  .toList() ??
              [],
        ),
      ),
    );
  }
}
