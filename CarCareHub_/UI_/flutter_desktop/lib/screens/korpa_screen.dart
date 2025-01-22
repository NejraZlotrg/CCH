import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class KorpaScreen extends StatefulWidget {
  const KorpaScreen({super.key});

  @override
  State<KorpaScreen> createState() => _KorpaScreenState();
}

class _KorpaScreenState extends State<KorpaScreen> {
  late KorpaProvider _korpaProvider;
  late NarudzbaProvider _narudzbaProvider;
  late UserProvider _userProvider;

  List<Korpa> korpaList = [];
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korpaProvider = context.read<KorpaProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _userProvider = context.read<UserProvider>();
    userId = _userProvider.userId;

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Korpa> data = await _korpaProvider.getById(userId);
      setState(() {
        korpaList = data;
      });
    } catch (e) {
      print('Greška prilikom učitavanja podataka iz korpe: $e');
    }
  }

  Future<void> _finishOrder() async {
    try {
      // Dohvati ID korisnika na osnovu tipa korisnika
      int? klijentId;
      int? autoservisId;
      int? zaposlenikId;

      // Prvo pokušaj dobiti ID klijenta
     if(_userProvider.role =='Klijent')
    
{
      // Kreiraj objekat za unos narudžbe
      final narudzbaObjekat = {
        "klijentId": _userProvider.userId,
        "autoservisId": null,
        "firmaAutodijelovaId": null,
        "zavrsenaNarudzba": true,
        "popustId": null,
      };

      // Poziv metode za unos narudžbe
      await _narudzbaProvider.insert(narudzbaObjekat);
}
if(_userProvider.role =='Autoservis')
    
{
      // Kreiraj objekat za unos narudžbe
      final narudzbaObjekat = {
        "klijentId": null,
        "autoservisId": _userProvider.userId,
        "ZaposlenikId": null,
        "zavrsenaNarudzba": true,
        "popustId": null,
      };

      // Poziv metode za unos narudžbe
      await _narudzbaProvider.insert(narudzbaObjekat);
}
if(_userProvider.role =='Zaposlenik')
    
{
      // Kreiraj objekat za unos narudžbe
      final narudzbaObjekat = {
        "klijentId": null,
        "autoservisId": null,
        "ZaposlenikId": _userProvider.userId,
        "zavrsenaNarudzba": true,
        "popustId": null,
      };

      // Poziv metode za unos narudžbe
      await _narudzbaProvider.insert(narudzbaObjekat);
}
      // Prikaz poruke korisniku
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narudžba je uspješno kreirana.')),
      );

      // Osvježavanje korpe nakon kreiranja narudžbe
      await _loadData();
    } catch (e) {
      print('Greška prilikom kreiranja narudžbe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška prilikom kreiranja narudžbe.')),
      );
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
            _buildDataListView(),
            _buildFinishOrderButton(),
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

  Widget _buildFinishOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _finishOrder,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Završi narudžbu'),
      ),
    );
  }
}
