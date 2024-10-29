import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/screens/grad_details_screen.dart';
//import 'package:flutter_mobile/screens/grad_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class GradScreen extends StatefulWidget {
  const GradScreen({super.key});

  @override
  State<GradScreen> createState() => _GradScreenState();
}

class _GradScreenState extends State<GradScreen> {
  late GradProvider _gradProvider;

  SearchResult<Grad>? result;
  final TextEditingController _nazivGradaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gradProvider = context.read<GradProvider>();
    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Grad",
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
                labelText: 'Naziv grada',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivGradaController,
            ),
          ),
          const SizedBox(width: 10),
          
          ElevatedButton(
onPressed: () async {
  print("Pokretanje pretrage za grad: ${_nazivGradaController.text}");

  var filterParams = {
    'IsDrzavaIncluded': 'true', // Ovaj parametar ostaje
  };

  // Dodavanje filtera samo ako je naziv unesen
  if (_nazivGradaController.text.isNotEmpty) {
    filterParams['Naziv'] = _nazivGradaController.text;
  }

  var data = await _gradProvider.get(filter: filterParams);

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
                     MaterialPageRoute(builder: (context)=> GradDetailsScreen(grad: null,) // poziv na drugi screen
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
      scrollDirection: Axis.vertical, // Vertikalni pomak
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Naziv grada',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv drzave',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            
          ],
          rows: result?.result
                .map(
                  (Grad e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.gradId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> GradDetailsScreen(grad: e,) // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.nazivGrada ?? "")),
                      DataCell(Text(e.drzava?.nazivDrzave ?? "")),
                    ],
                  ),
                )
                .toList() ?? [],
        ),
        ),
    );
  }
}
