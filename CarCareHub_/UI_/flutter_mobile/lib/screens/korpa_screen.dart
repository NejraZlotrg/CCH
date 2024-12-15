import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class KorpaScreen extends StatefulWidget {
  @override
  State<KorpaScreen> createState() => _KorpaScreenState();
}

class _KorpaScreenState extends State<KorpaScreen> {
  late KorpaProvider _korpaProvider;
  List<Korpa> korpaList = [];
  late String userRole;
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korpaProvider = context.read<KorpaProvider>();
    final userProvider = context.read<UserProvider>();

    userId = userProvider.userId;  // Assuming you have userId in UserProvider
    userRole = userProvider.role;  // Assuming you have user role in UserProvider
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Korpa> data = await _korpaProvider.getById(userId);
      setState(() {
        korpaList = data;
      });
    } catch (e) {
      print('Error fetching korpa data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Korpa",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204),
        child: Column(
          children: [
            // Your search widget goes here
            _buildDataListView(),
          ],
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
          side: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Proizvod ID')),
              DataColumn(label: Text('Klijent ID')),
              DataColumn(label: Text('Zaposlenik ID')),
              DataColumn(label: Text('Autoservis ID')),
              DataColumn(label: Text('Količina')),
              DataColumn(label: Text('Ukupna cijena')),
            ],
            rows: korpaList.map((Korpa e) {
              return DataRow(
                onSelectChanged: (selected) {
                  if (selected == true) {
                    // Handle row selection logic here
                  }
                },
                cells: [
                  DataCell(Text(e.proizvodId?.toString() ?? "")),
                  DataCell(Text(e.klijentId?.toString() ?? "")),
                  DataCell(Text(e.zaposlenikId?.toString() ?? "")),
                  DataCell(Text(e.autoservisId?.toString() ?? "")),
                  DataCell(Text(e.kolicina?.toString() ?? "")),
                  DataCell(Text(e.ukupnaCijenaProizvoda?.toStringAsFixed(2) ?? "")),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
