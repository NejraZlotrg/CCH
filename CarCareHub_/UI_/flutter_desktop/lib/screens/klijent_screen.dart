import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/screens/klijent_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class KlijentScreen extends StatefulWidget {
  const KlijentScreen({super.key});

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
    _loadData();
  }

  Future<void> _loadData() async {
    SearchResult<Klijent> data;
    if (context.read<UserProvider>().role == "Admin")
     data = await _klijentProvider.getAdmin(filter: {'IsAllncluded': 'true'});
    else 
     data = await _klijentProvider.get(filter: {'IsAllncluded': 'true'});
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Klijent",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204),
       // child: SingleChildScrollView( // Omogućava vertikalno skrolanje cijelog ekrana
          child: Column(
            children: [
              _buildSearch(),
              _buildDataListView(),
            ],
          ),
        ),
    //  ),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Ime",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _imeController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Prezime",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _prezimeController,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  var filterParams = {'IsAllncluded': 'true'};
                  if (_imeController.text.isNotEmpty) {
                    filterParams['ime'] = _imeController.text;
                  }
                  if (_prezimeController.text.isNotEmpty) {
                    filterParams['prezime'] = _prezimeController.text;
                  }
                  SearchResult<Klijent> data;
                  if (context.read<UserProvider>().role == "Admin")
                   data = await _klijentProvider.getAdmin(filter: filterParams);
                  else 
                   data = await _klijentProvider.get(filter: filterParams);
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KlijentDetailsScreen(klijent: null),
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
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
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
          ],
          rows: result?.result
                  .map(
                    (Klijent e) => DataRow(
                      onSelectChanged: (selected) async {
                        if (selected == true) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  KlijentDetailsScreen(klijent: e),
                            ),
                          );
                          await _loadData();
                        }
                      },
                      cells: [
                        DataCell(Text(e.ime ?? "")),
                        DataCell(Text(e.prezime ?? "")),
                        DataCell(Text(e.username ?? "")),
                        DataCell(Text(e.email ?? "")),
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