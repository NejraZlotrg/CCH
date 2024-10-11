import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/screens/klijent_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class KlijentScreen extends StatefulWidget {
  const KlijentScreen({Key? key}) : super(key: key);

  @override
  State<KlijentScreen> createState() => _KlijentScreenState();
}

class _KlijentScreenState extends State<KlijentScreen> {
  late KlijentProvider _klijentProvider;
  SearchResult<Klijent>? result;
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _klijentProvider = context.read<KlijentProvider>();
    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Klijent",
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
              controller: _imeController,
              decoration: const InputDecoration(
                labelText: "Ime",
                border: OutlineInputBorder(),
                
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _prezimeController,
              decoration: const InputDecoration(
                labelText: "Prezime",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              print("podaci proceed");
             var data = await _klijentProvider.get(filter: {
  'ime': _imeController.text,
  'prezime': _prezimeController.text,
});
print("Preuzeti podaci: $data");


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
        ],
      ),
    );
  }

  Widget _buildDataListView() {
  return Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical, // Vertikalni pomak
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'KlijentId',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Ime',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Prezime',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Username',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            /*DataColumn(
              label: Text(
                'Password',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'LozinkaSalt',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'LozinkaHash',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Spol',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'BrojTelefona',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'GradId',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),*/
          ],
          rows: result?.result
                .map(
                  (Klijent e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.klijentId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> KlijentDetailsScreen(klijent: e,) // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.klijentId?.toString() ?? "")),
                      DataCell(Text(e.ime ?? "")),
                      DataCell(Text(e.prezime ?? "")),
                      DataCell(Text(e.username ?? "")),
                      DataCell(Text(e.email ?? "")),
                   /*   DataCell(Text(e.password ?? "")),
                      DataCell(Text(e.lozinkaSalt ?? "")),
                      DataCell(Text(e.lozinkaHash ?? "")),
                      DataCell(Text(e.spol ?? "")),
                      DataCell(Text(e.brojTelefona ?? "")),
                      DataCell(Text(formatNumber(e.gradId))),*/
                    ],
                  ),
                )
                .toList() ?? [],
        ),

     /*     rows: result?.result
                  .map(
                    (Klijent e) => DataRow(
                      onSelectChanged: (selected) {
                        if(selected == true) {
                          print('selected: ${e.KlijentId}');
                          //Navigator.of(context).push(
                          //  MaterialPageRoute(builder: (context)=> ProductDetailScreen(product: e,) // poziv na drugi screen
                         // ), );
                        }

                      },
                      cells: [
                        DataCell(Text(e.KlijentId?.toString() ?? "")),
                        DataCell(Text(e.Ime ?? "")),
                        DataCell(Text(e.Prezime ?? "")),
                    /*    DataCell(Text(e.Username ?? "")),
                        DataCell(Text(e.Email ?? "")),
                        DataCell(Text(e.Password ?? "")),
                        DataCell(Text(e.LozinkaSalt ?? "")),
                        DataCell(Text(e.LozinkaHash ?? "")),
                        DataCell(Text(e.Spol ?? "")),
                        DataCell(Text(e.BrojTelefona ?? "")),
                        DataCell(Text(formatNumber(e.GradId))),*/
                      ],
                    ),
                  )
                  .toList() ??
              [],*/
        ),
    );
  }
}
