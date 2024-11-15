import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
//import 'package:flutter_mobile/screens/product_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class NarudzbaScreen extends StatefulWidget {
  const NarudzbaScreen({super.key});

  @override
  State<NarudzbaScreen> createState() => _NarudzbaScreenState();
}

class _NarudzbaScreenState extends State<NarudzbaScreen> {
  late NarudzbaProvider _narudzbaProvider;
  SearchResult<Narudzba>? result;
 // final TextEditingController _nazivController = TextEditingController();
 // final TextEditingController _modelController= TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Narudzbe",
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
          

         ElevatedButton(
            onPressed: () async {
              print("podaci proceed");
              var data = await _narudzbaProvider.get(filter: {
              //  'naziv': _nazivController.text,
                //'model': _modelController.text
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
                Text('Prikazi narudzbu'),
              ],

            ),
          ),
          // Novo dugme za kreiranje nove narudžbe
        ElevatedButton(
          onPressed: () async {
            // Kreiranje nove narudžbe pozivom na backend
            await _narudzbaProvider.createNewNarudzba();

            // Nakon kreiranja nove narudžbe, osvježi listu
            var data = await _narudzbaProvider.get();
            setState(() {
              result = data;
            });

            print("Nova narudžba kreirana!");
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8.0),
              Text('Dodaj novu narudžbu'),
            ],
          ),
        ),
          const SizedBox(width: 10),

        /*  ElevatedButton(
            onPressed: () async {

                     Navigator.of(context).push(
                     MaterialPageRoute(builder: (context)=> NarudzbaDetailScreen(product: null,) // poziv na drugi screen
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
          ),*/
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
                'Narudzba ID',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Datum narudzbe',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Datum isporuke',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Zavrsena narudzba',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
           
           
          ],
          rows: result?.result
                  .map(
                    (Narudzba e) => DataRow(
                     /* onSelectChanged: (selected) {
                        if(selected == true) {
                          print('selected: ${e.narudzbaId}');
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=> ProductDetailScreen(product: e,) // poziv na drugi screen
                          ), );
                        }

                      },*/
                      cells: [
                        DataCell(Text(e.zavrsenaNarudzba.toString())),
                        DataCell(Text(e.datumIsporuke.toString())),
                        DataCell(Text(e.datumIsporuke.toString())),
                        
                        DataCell(Text(e.zavrsenaNarudzba.toString())),
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
