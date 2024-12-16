import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/models/narudzba.dart'; // Model za narudžbu
import 'package:flutter_mobile/models/narudzba_stavke.dart'; // Model za stavke narudžbe
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart'; // Provider za kreiranje narudžbi
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class KorpaScreen extends StatefulWidget {
  @override
  State<KorpaScreen> createState() => _KorpaScreenState();
}

class _KorpaScreenState extends State<KorpaScreen> {
  late KorpaProvider _korpaProvider;
  final _formKey = GlobalKey<FormBuilderState>();

  late NarudzbaProvider _narudzbaProvider;
  List<Korpa> korpaList = [];
  late String userRole;
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korpaProvider = context.read<KorpaProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    final userProvider = context.read<UserProvider>();

    userId = userProvider.userId;  // Pretpostavljamo da imate userId u UserProvider
    userRole = userProvider.role;  // Pretpostavljamo da imate role u UserProvider
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
            _buildDataPreview(), // Dodajemo ispis unesenih podataka
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

  // Metoda za izgradnju dugmeta "Završi narudžbu"
  Widget _buildFinishOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // Pokrećemo logiku za završavanje narudžbe
          _completeOrder();
        },
        child: Text('Završi narudžbu'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          textStyle: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  // Metoda za ispis unesenih podataka
  Widget _buildDataPreview() {
    final formValues = _formKey.currentState?.value;
    return Column(
      children: [
        Text('Datum narudžbe: ${formValues?['datumNarudzbe'] ?? 'N/A'}'),
        Text('Datum isporuke: ${formValues?['datumIsporuke'] ?? 'N/A'}'),
        // Dodajte ostale vrijednosti po potrebi
      ],
    );
  }

  Future<void> _completeOrder() async {
  try {
    // Step 1: Uzmi trenutni datum i datum isporuke
    DateTime currentDate = DateTime.now().toUtc(); // Postavljanje na UTC
    DateTime deliveryDate = DateTime.now().add(Duration(days: 3)).toUtc(); // Datum isporuke 3 dana od sada (UTC)

    // Konvertuj u ISO 8601 format sa UTC 'Z'
    String formattedCurrentDate = currentDate.toIso8601String();
    String formattedDeliveryDate = deliveryDate.toIso8601String();

    // Step 2: Kreiraj novu narudžbu (Narudzba)
    var orderRequest = {
      'datumNarudzbe': formattedCurrentDate,
      'datumIsporuke': formattedDeliveryDate,
      'zavrsenaNarudzba': false,
      'popustId': null,
      'ukupnaCijenaNarudzbe': 0.0,
      'klijentId': userId, // Klijent je korisnik koji pravi narudžbu
    };

    // Kreiraj narudžbu
    Narudzba newOrder = await _narudzbaProvider.insert(orderRequest);

    // Step 3: Kreiraj stavke narudžbe (NarudzbaStavka) za svaki proizvod u korpi
    double totalPrice = 0.0;

    if (korpaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Korpa je prazna!')),
      );
      return;
    }

    for (Korpa item in korpaList) {
      if (item.proizvodId == null || item.kolicina == null || item.ukupnaCijenaProizvoda == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nema validnih podataka u korpi!')),
        );
        return;
      }

      // Kreiraj stavku narudžbe za svaku stavku u korpi
      var orderItemRequest = {
        'narudzbaId': newOrder.narudzbaId, // Povezivanje stavke sa narudžbom
        'proizvodId': item.proizvodId,
        'kolicina': item.kolicina,
        'ukupnaCijena': item.ukupnaCijenaProizvoda,
      };

      // Dodaj stavku narudžbe
      await _narudzbaProvider.insert(orderItemRequest);

      // Dodaj cijenu stavke na ukupnu cijenu narudžbe
      totalPrice += item.ukupnaCijenaProizvoda! * item.kolicina!;
    }

    // Step 4: Ažuriraj narudžbu sa ukupnom cijenom
    // if (totalPrice > 0) {
    //   await _narudzbaProvider.updateTotalPrice(newOrder.narudzbaId, totalPrice);
    // }

    // Step 5: Opcionalno, očisti korpu nakon uspješne narudžbe
  //  await _korpaProvider.clearKorpa(userId);

    // Obavijesti korisnika da je narudžba završena
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Narudžba je uspješno završena!')),
    );
  } catch (e) {
    print('Greška pri završavanju narudžbe: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Došlo je do greške pri završavanju narudžbe!')),
    );
  }
}

}
