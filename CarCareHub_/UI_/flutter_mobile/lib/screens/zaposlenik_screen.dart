import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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
   _loadData();
  }
 Future<void> _loadData() async {
  var data = await _zaposlenikProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
  }
}
   @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Zaposlenici",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204), // Dodana siva pozadina
        child: Column(
          children: [
            _buildSearch(),
            _buildDataListView(),
          ],
        ),
      ),
    );
  }
  Widget _buildSearch() {
  return Container(
    width: MediaQuery.of(context).size.width, // Širina 100% ekrana
    margin: const EdgeInsets.only(
      top: 20.0, // Razmak od vrha
    ),
    child: Card(
      elevation: 4.0, // Dodaje malo sjene za karticu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0), // Zaobljeni uglovi kartice
        side: const BorderSide(
          color: Colors.black, // Crni okvir
          width: 1.0, // Debljina okvira (1px)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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

                var filterParams = {
               'IsAllIncluded': 'true', // Ovaj parametar ostaje
                   };

                   
  // Dodavanje filtera samo ako je naziv unesen
                if (_imeController.text.isNotEmpty) {
                     filterParams['ime'] = _imeController.text;
                        }
                       if (_prezimeController.text.isNotEmpty) {
                     filterParams['prezime'] = _prezimeController.text;
                        }
              var data = await _zaposlenikProvider.get(filter: filterParams);


              setState(() {
                result = data;
              });
            },
                          style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Crvena boja dugmeta
                foregroundColor: Colors.white, // Bijela boja teksta
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Zaobljeni uglovi
                ),
                          ),
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
                 if (context.read<UserProvider>().role == "Admin")
                  ElevatedButton(
                  onPressed: () async {
                    await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ZaposlenikDetailsScreen(zaposlenik: null),
                              ),
                            );
                    await _loadData();

            },
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Crvena boja dugmeta
                foregroundColor: Colors.white, // Bijela boja teksta
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Zaobljeni uglovi
                ),),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8.0),
                Text('Dodaj'),
              ],
              ),
            ),
            const SizedBox(width: 10),
         
          ],
        ),
      ),
    ),
  );
}




  Widget _buildDataListView() {
  return Container(
    width: MediaQuery.of(context).size.width * 1, // Širina 90% ekrana
    margin: const EdgeInsets.only(
      top: 20.0, // Razmak od vrha
    ),
    child: Card(
      elevation: 4.0, // Dodaje malo sjene za karticu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0), // Zaobljeni uglovi kartice
        side: const BorderSide(
          color: Colors.black, // Crni okvir
          width: 1.0, // Debljina okvira (1px)
        ),
      ),
      child: SingleChildScrollView(
        child: DataTable(
                    showCheckboxColumn: false,

          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ime', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Prezime', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Grad', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Uloga', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: result?.result.map((Zaposlenik e) {
            return DataRow(
              onSelectChanged: (selected) async {
                if (selected == true) {
                await   Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ZaposlenikDetailsScreen( zaposlenik: e,),
                    ),
                  );
                    await _loadData();

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
               DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.grad?.nazivGrada ?? ""),
                )),
                DataCell(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.uloga?.nazivUloge ?? ""),
                )),
              ],
            );
          }).toList() ?? [],
         ),
      ),
    ),
  );
}

}