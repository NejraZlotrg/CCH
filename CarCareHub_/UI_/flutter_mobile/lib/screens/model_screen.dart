import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/screens/model_details_screen.dart';
//import 'package:flutter_mobile/screens/grad_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  late ModelProvider _modelProvider;
  

  SearchResult<Model>? result;
  final TextEditingController _nazivModelaController = TextEditingController();
  final TextEditingController _markaVozilaController = TextEditingController();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modelProvider = context.read<ModelProvider>();
   

    
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Model",
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
                labelText: 'Marka vozila',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _markaVozilaController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Naziv modela',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivModelaController,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
onPressed: () async {
  print("Pokretanje pretrage: ${_nazivModelaController.text} i ${_markaVozilaController.text}");

  var filterParams = {
    'IsAllIncluded': 'true', // Ovaj parametar ostaje
  };

  // Dodavanje filtera samo ako je naziv unesen
  if (_nazivModelaController.text.isNotEmpty || _markaVozilaController.text.isNotEmpty) {
    filterParams['nazivModela'] = _nazivModelaController.text;
    filterParams['markaVozila'] = _markaVozilaController.text;

  }

  var data = await _modelProvider.get(filter: filterParams, );

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
                     MaterialPageRoute(builder: (context)=> ModelDetailsScreen(model: null,) // poziv na drugi screen
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
                'Marka vozila',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv modela',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Godiste',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                .map(
                  (Model e) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        print('Selected: ${e.modelId}');
                        // Ovdje možeš dodati navigaciju ili akciju za detalje
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> ModelDetailsScreen(model: e,) 
                       // poziv na drugi screen
                         ), );
                      }
                    },
                    cells: [
                      DataCell(Text(e.vozilo?.markaVozila ?? "")),
                      DataCell(Text(e.nazivModela ?? "")),
                      DataCell(Text(e.godiste!.godiste_.toString())),

                    ],
                  ),
                )
                .toList() ?? [],
        ),
        ),
    );
  }
}
