import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/models/placanje_insert.dart';
import 'package:flutter_mobile/models/rezultat_placanja.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/placanje_provider.dart';
import 'package:flutter_mobile/screens/placanje_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show Address, BillingDetails, SetupPaymentSheetParameters, Stripe;
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
  late PlacanjeProvider placanjeProvider;

  List<Korpa> korpaList = [];
  late int userId;
  late double ukupnaCijena;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korpaProvider = context.read<KorpaProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _userProvider = context.read<UserProvider>();
    placanjeProvider = context.read<PlacanjeProvider>();
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

void handlePayment(dynamic narudzba) async {
  print("handlePayment called");
  try {
    double ukupno = narudzba['ukupnaCijenaNarudzbe'] * 100;
    print("Creating payment intent for amount: $ukupno");

    // Call the create method and get the RezultatPlacanja object
    RezultatPlacanja paymentResult = await placanjeProvider.create(PlacanjeInsert(ukupno: ukupno));
    print("Payment intent created: ${paymentResult.clientSecret}");

    // Initialize the payment sheet with the client secret
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentResult.clientSecret,
        merchantDisplayName: 'CarCareHub',
        billingDetails: const BillingDetails(
          address: Address(
            city: 'Mostar',
            country: 'BA',
            line1: '',
            line2: '',
            postalCode: '',
            state: '',
          ),
        ),
      ),
    );
    print("Payment sheet initialized");

    // Present the payment sheet to the user
    displayPaymentSheet(context, narudzba);
  } catch (e) {
    print('Greška prilikom plaćanja: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška prilikom plaćanja: $e')),
    );
  }
}

  void displayPaymentSheet(BuildContext context, dynamic narudzba) async {
      print("displayPaymentSheet called"); // Add this line

    await Stripe.instance.presentPaymentSheet().then((value) async {
      handleSubmit(narudzba);
    });
  }

  void handleSubmit(dynamic narudzba) async {
    await _narudzbaProvider.insert(narudzba);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Narudžba je uspješno kreirana.')),
    );
  }

  Future<void> _finishOrder() async {
      print("_finishOrder called"); // Add this line
    try {
      // Dohvati ID korisnika na osnovu tipa korisnika

      late dynamic narudzbaObjekat;
      // Prvo pokušaj dobiti ID klijenta
      if (_userProvider.role == 'Klijent') {
        // Kreiraj objekat za unos narudžbe
        narudzbaObjekat = {
          "klijentId": _userProvider.userId,
          "autoservisId": null,
          "firmaAutodijelovaId": null,
          "zavrsenaNarudzba": true,
          "popustId": null,
        };

        // Poziv metode za unos narudžbe
      }
      if (_userProvider.role == 'Autoservis') {
        // Kreiraj objekat za unos narudžbe
        narudzbaObjekat = {
          "klijentId": null,
          "autoservisId": _userProvider.userId,
          "ZaposlenikId": null,
          "zavrsenaNarudzba": true,
          "popustId": null,
        };

        // Poziv metode za unos narudžbe
      }
      if (_userProvider.role == 'Zaposlenik') {
        // Kreiraj objekat za unos narudžbe
        narudzbaObjekat = {
          "klijentId": null,
          "autoservisId": null,
          "ZaposlenikId": _userProvider.userId,
          "zavrsenaNarudzba": true,
          "popustId": null,
        };

        // Poziv metode za unos narudžbe
      }

      narudzbaObjekat = {...narudzbaObjekat, 'ukupnaCijenaNarudzbe': ukupnaCijena};

     handlePayment(narudzbaObjekat);

      // Osvježavanje korpe nakon kreiranja narudžbe
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
            _buildPlatiButton()
          ],
        ),
      ),
    );
  }

  Widget _buildDataListView() {
    // Izračunavamo ukupnu cijenu pre nego što prikažemo podatke
    ukupnaCijena = korpaList.fold(0.0, (sum, e) {
      return sum + (e.ukupnaCijenaProizvoda ?? 0.0);
    });

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
          child: Column(
            children: [
              // Prikazujemo podatke po redovima umesto po kolonama
              ...korpaList
                  .asMap()
                  .map((index, e) {
                    // Prikazujemo Kupca samo prvi put
                    bool isFirst = index == 0;
                    return MapEntry(
                      index,
                      Column(
                        children: [
                          // Prikazivanje samo jednog reda za Kupca
                          if (isFirst) _buildKupacRow(e),
                          _buildRow('Naziv proizvoda', e.proizvodId),
                          _buildRow('Količina', e.kolicina),
                          _buildRow('Cijena',
                              e.ukupnaCijenaProizvoda?.toStringAsFixed(2)),
                              if (index != korpaList.length - 1) // Ne dodajemo divider posljednjem proizvodu
                          const Divider(
                            color: Colors.black,
                            thickness: 1.0,
                            indent: 15.0, // Space at the start of the line
                            endIndent: 100.0, // Space at the end of the line
                          ),
                        ],
                      ),
                    );
                  })
                  .values
                  .toList(),

              // Dodajemo Divider iznad ukupne cijene
              const Divider(
                color: Colors.black,
                thickness: 5.0,
                indent: 10.0,
                endIndent: 10.0,
              ),

              // Dodajemo red za ukupnu cijenu
              _buildRow('Ukupna cijena', ukupnaCijena.toStringAsFixed(2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKupacRow(Korpa e) {
    // Prikazujemo samo onaj ID koji nije null
    String kupacLabel = 'Kupac: ';
    if (e.klijentId != null) {
      kupacLabel += e.klijentId.toString();
    } else if (e.zaposlenikId != null) {
      kupacLabel += e.zaposlenikId.toString();
    } else if (e.autoservisId != null) {
      kupacLabel += e.autoservisId.toString();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            kupacLabel,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value?.toString() ?? '',
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }


  Widget _buildPlatiButton() {
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
