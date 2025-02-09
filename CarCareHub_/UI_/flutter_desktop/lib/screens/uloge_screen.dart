import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/screens/uloge_details_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
 
class UlogeScreen extends StatefulWidget {
  const UlogeScreen({super.key});
 
  @override
  State<UlogeScreen> createState() => _UlogeScreenState();
}
 
class _UlogeScreenState extends State<UlogeScreen> {
  late UlogeProvider _ulogeProvider;
  SearchResult<Uloge>? result;
  final TextEditingController _nazivUlogeController = TextEditingController();
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ulogeProvider = context.read<UlogeProvider>();
    _fetchInitialData();
  }
   Future<void> _fetchInitialData() async {
    try {
      SearchResult<Uloge> data;
      if (context.read<UserProvider>().role == "Admin")
       data = await _ulogeProvider.getAdmin(filter: {'IsAllncluded': 'true',});
      else
       data = await _ulogeProvider.get(filter: {'IsAllncluded': 'true',});

      if (mounted) {
        setState(() {
          result = data;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Uloge",
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Naziv uloge',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _nazivUlogeController,
                ),
              ),
              const SizedBox(width: 10),
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
              const SizedBox(width: 10),
                     if (context.read<UserProvider>().role == "Admin")
              ElevatedButton(
                  onPressed: () async {
                    await  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    UlogeDetailsScreen(uloge: null),
                              ),
                            );
                    await _fetchInitialData();
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
    if (_nazivUlogeController.text.isNotEmpty) {
      filterParams['nazivUloge'] = _nazivUlogeController.text;
    }
  SearchResult<Uloge> data;
    if (context.read<UserProvider>().role == "Admin")
     data = await _ulogeProvider.getAdmin(filter: filterParams);
    else 
     data = await _ulogeProvider.get(filter: filterParams);

 
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
                'Naziv uloge',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16, // Veći font za naziv kolone
                ),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (Uloge e) => DataRow(
                      onSelectChanged: (selected) async {
                        if (selected == true) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  UlogeDetailsScreen(uloge: e),
                            ),
                          );
                          await _fetchInitialData();
                        }
                      },
                      cells: [
                        DataCell(
                          Text(
                            e.nazivUloge.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: e.vidljivo == false ? Colors.red : Colors.black,
                              fontWeight:
                                  e.vidljivo == false ? FontWeight.bold : FontWeight.normal,
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

 