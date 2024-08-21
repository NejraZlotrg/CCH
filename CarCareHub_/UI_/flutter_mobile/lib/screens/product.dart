import 'package:flutter/material.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
    const ProductScreen({Key? key}) : super(key: key);
   
   
@override
State<ProductScreen>createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
late ProductProvider _productProvider;

 @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
  }
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Proizvodi",
      child: Center(
        child: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
              print("podaci proceed");
              var data = await _productProvider.get();
              print("data:$data");
              },
              child: Text("podaci")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Naziv firme",
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
                    onPressed: () {
                    // Dodaj funkcionalnost pretrage ovde
                  },
                  child: const Row(
                   mainAxisSize: MainAxisSize.min, // Da bi dugme bilo što uže moguće
                   children: [
                     Icon(Icons.search), // Ikonica
                     SizedBox(width: 8.0), // Razmak između ikonice i teksta
                     Text('Pretraga'), // Tekst
                   ],
                 ),
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: List.generate(6, (index) {
                return Card(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Image.network(
                          'https://via.placeholder.com/150', // zamijenite stvarnim URL-om slike
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Proizvod ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Cijena: ${100 * (index + 1)} KM'),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
