import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/usluge.dart'; 
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
 
import 'package:flutter_mobile/screens/usluge_details_screen.dart'; 
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
 
class UslugeScreen extends StatefulWidget {
  const UslugeScreen({super.key});
 
  @override
  State<UslugeScreen> createState() => _UslugeScreenState();
}
 
class _UslugeScreenState extends State<UslugeScreen> {
  late UslugeProvider _uslugaProvider;
  SearchResult<Usluge>? result;
  final TextEditingController _nazivUslugeController = TextEditingController();
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uslugaProvider = context.read<UslugeProvider>();
     _loadData();
  }
 Future<void> _loadData() async {
  SearchResult<Usluge> data;
  if (context.read<UserProvider>().role == "Admin") {
    data = await _uslugaProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
  } else {
    data = await _uslugaProvider.get(filter: {'IsAllIncluded': 'true'});
  }

  if (mounted) {
    setState(() {
      result = data;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Usluge",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204),
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
                labelText: 'Naziv usluge',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nazivUslugeController,
            ),
            
            const SizedBox(height: 10),
            
          
            Row(
              children: [
             
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _onSearchPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8.0),
                        Text('Pretraga'),
                      ],
                    ),
                  ),
                ),
                
                if (context.read<UserProvider>().role == "Admin") ...[
                  const SizedBox(width: 10),
              
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UslugeDetailsScreen(usluge: null),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8.0),
                          Text('Dodaj'),
                        ],
                      ),
                    ),
                  ),
                ],
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
    if (_nazivUslugeController.text.isNotEmpty) {
      filterParams['nazivUsluge'] = _nazivUslugeController.text;
    }
    SearchResult<Usluge> data;
  if (context.read<UserProvider>().role == "Admin") {
    data = await _uslugaProvider.getAdmin(filter: filterParams);
  } else {
    data = await _uslugaProvider.get(filter: filterParams);
  }

 
    if (!mounted) return;
 
    setState(() {
      result = data;
    });
  }
 Widget _buildDataListView() {
  return Expanded(
    child: SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 20.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.0),
            side: const BorderSide(color: Colors.black, width: 1.0),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [
                DataColumn(
                  label: Text(
                    'Naziv usluge',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16, 
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Cijena',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
              rows: result?.result
                      .map(
                        (Usluge e) => DataRow(
                          onSelectChanged: (selected) async {
                            if (selected == true) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UslugeDetailsScreen(usluge: e),
                                ),
                              );
                              await _loadData();
                            }
                          },
                          cells: [
                            DataCell(
                              Text(
                                e.nazivUsluge ?? "",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "${e.cijena?.toStringAsFixed(2)} KM",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: (e.cijena ?? 0) <= 0
                                      ? Colors.red
                                      : Colors.black,
                                  fontWeight: (e.cijena ?? 0) <= 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
      ),
    ),
  );
}

}