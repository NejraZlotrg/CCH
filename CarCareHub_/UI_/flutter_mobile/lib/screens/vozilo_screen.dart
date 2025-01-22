import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/screens/vozilo_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
 
class VoziloScreen extends StatefulWidget {
  const VoziloScreen({super.key});
 
  @override
  State<VoziloScreen> createState() => _VoziloScreenState();
}
 
class _VoziloScreenState extends State<VoziloScreen> {
  late VoziloProvider _voziloProvider;
  SearchResult<Vozilo>? result;
  final TextEditingController _markaVozilaController = TextEditingController();
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _voziloProvider = context.read<VoziloProvider>();
     _loadData();
  }
 Future<void> _loadData() async {
  var data = await _voziloProvider.get(filter: {'IsAllIncluded': 'true'});
  if (mounted) {
    setState(() {
      result = data;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Marka vozila",
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
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Marka vozila',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _markaVozilaController,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSearchPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
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
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VoziloDetailsScreen(vozilo: null),
                        ),
                      );
                      await _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
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
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

 
  Future<void> _onSearchPressed() async {
    var filterParams = {'IsAllIncluded': 'true'};
    if (_markaVozilaController.text.isNotEmpty) {
      filterParams['markaVozila'] = _markaVozilaController.text;
    }
 
    var data = await _voziloProvider.get(filter: filterParams);
 
    if (!mounted) return;
 
    setState(() {
      result = data;
    });
  }
 
  Widget _buildDataListView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 20.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
          side: const BorderSide(color: Colors.black, width: 1.0),
        ),
        child: SingleChildScrollView(
          child: DataTable(
                      showCheckboxColumn: false,

            columns: const [
              DataColumn(
                label: Text(
                  'Marka vozila',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          rows: result?.result
                    .map(
                      (Vozilo e) => DataRow(
                        onSelectChanged: (selected) async  {
                          if (selected == true) {
                           await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    VoziloDetailsScreen(vozilo: e),
                              ),
                            );
                    await _loadData();

                  }
                },
                cells: [
                  DataCell(Text(e.markaVozila.toString())),
                ],
             
                      ),
                    )
                    .toList() ??
                [],
          ),
        ),
      ),
    );
  }
}
