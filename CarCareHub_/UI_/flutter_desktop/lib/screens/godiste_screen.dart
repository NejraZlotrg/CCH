import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/screens/godiste_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class GodisteScreen extends StatefulWidget {
  const GodisteScreen({super.key});

  @override
  State<GodisteScreen> createState() => _GodisteScreenState();
}

class _GodisteScreenState extends State<GodisteScreen> {
  late GodisteProvider _godisteProvider;
  SearchResult<Godiste>? result;
  final TextEditingController _nazivModelaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _godisteProvider = context.read<GodisteProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    SearchResult<Godiste> data;
    if (context.read<UserProvider>().role == "Admin")
     data = await _godisteProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
    else 
      data = await _godisteProvider.get(filter: {'IsAllIncluded': 'true'});
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Godiste",
      child: SingleChildScrollView( // Added scrolling to the entire screen
        child: Container(
          color: const Color.fromARGB(255, 204, 204, 204),
          child: Column(
            children: [
              _buildSearch(),
              _buildDataListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(
        top: 20.0,
      ),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
          side: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Godiste:',
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
                  var filterParams = {
                    'IsAllIncluded': 'true',
                  };

                  if (_nazivModelaController.text.isNotEmpty) {
                    filterParams['godiste_'] = _nazivModelaController.text;
                  }
                  SearchResult<Godiste> data;
                  if (context.read<UserProvider>().role == "Admin")
                   data = await _godisteProvider.getAdmin(filter: filterParams);
                  else 
                   data = await _godisteProvider.get(filter: filterParams);
                  if (!mounted) return;

                  setState(() {
                    result = data;
                  });
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
                                    GodisteDetailsScreen(godiste: null),
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
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataListView() {
  return Container(
    width: MediaQuery.of(context).size.width * 1,
    margin: const EdgeInsets.only(top: 20.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(
              label: Text(
                'Godiste:',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (Godiste e) => DataRow(
                      onSelectChanged: (selected) async {
                        if (selected == true) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  GodisteDetailsScreen(godiste: e),
                            ),
                          );
                          await _loadData();
                        }
                      },
                      cells: [
                        DataCell(
                          Text(
                            e.godiste_.toString(),
                            style: TextStyle(
                              color: e.vidljivo == false ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
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
