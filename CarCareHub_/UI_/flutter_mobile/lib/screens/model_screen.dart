import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/screens/model_details_screen.dart';
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
    _loadData();
  }
 Future<void> _loadData() async {
  var data = await _modelProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Model",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
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
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(top: 20.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Za širenje u širinu
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Marka vozila',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _markaVozilaController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Naziv modela',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivModelaController,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
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
            const SizedBox(height: 10),
            if (context.read<UserProvider>().role == "Admin")
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ModelDetailsScreen(model: null),
                    ),
                  );
                  await _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8.0),
                    Text('Dodaj'),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

 
  Future<void> _onSearchPressed() async {
    var filterParams = {'IsAllIncluded': 'true'};
    if (_nazivModelaController.text.isNotEmpty || _markaVozilaController.text.isNotEmpty) {
      filterParams['nazivModela'] = _nazivModelaController.text;
      filterParams['markaVozila'] = _markaVozilaController.text;
    }
 
    var data = await _modelProvider.get(filter: filterParams);
 
    if (!mounted) return;
 
    setState(() {
      result = data;
    });
  }
 Widget _buildDataListView() {
  return Expanded( // Koristimo Expanded kako bi popunili preostali prostor
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Omogućavamo skrolovanje za ceo sadržaj
        child: Container(
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(top: 20.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
        child: DataTable(
          showCheckboxColumn: false,
          dataTextStyle: TextStyle(fontSize: 14), // Manja veličina fonta
          columns: const [
              DataColumn(
              label: Text(
                'Marka vozila',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            ),
            DataColumn(
              label: Text(
                'Naziv modela',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            ),
          
          
          ],
          rows: result?.result
              .map(
                (Model e) => DataRow(
                  onSelectChanged: (selected) async {
                    if (selected == true) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ModelDetailsScreen(model: e),
                        ),
                      );
                      await _loadData();
                    }
                  },
                  cells: [
                      DataCell(Text(
                      e.vozilo?.markaVozila ?? "",
                      style: TextStyle(fontSize: 14),
                    )),
                    DataCell(Text(
                      e.nazivModela ?? "",
                      style: TextStyle(fontSize: 14), // Manja veličina fonta za svaku ćeliju
                    )),
                  
                   
                  ],
                ),
              )
              .toList() ??
              [],
        ),
      ),
    ),
      ));
}

}