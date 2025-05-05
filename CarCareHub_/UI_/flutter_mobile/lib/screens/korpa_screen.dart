import 'dart:convert';

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
    print("displayPaymentSheet called");
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
    print("_finishOrder called");
    try {
      late dynamic narudzbaObjekat;
      if (_userProvider.role == 'Klijent') {
        narudzbaObjekat = {
          "klijentId": _userProvider.userId,
          "autoservisId": null,
          "firmaAutodijelovaId": null,
          "zavrsenaNarudzba": true,
          "popustId": null,
        };
      }
      if (_userProvider.role == 'Autoservis') {
        narudzbaObjekat = {
          "klijentId": null,
          "autoservisId": _userProvider.userId,
          "ZaposlenikId": null,
          "zavrsenaNarudzba": true,
          "popustId": null,
        };
      }
      if (_userProvider.role == 'Zaposlenik') {
        narudzbaObjekat = {
          "klijentId": null,
          "autoservisId": null,
          "ZaposlenikId": _userProvider.userId,
          "zavrsenaNarudzba": true,
          "popustId": null,
        };
      }

      narudzbaObjekat = {...narudzbaObjekat, 'ukupnaCijenaNarudzbe': ukupnaCijena};

      handlePayment(narudzbaObjekat);
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
        child: 
        SingleChildScrollView(
        child: Column(
          children: [
            _buildDataListView(),
            _buildPlatiButton(),
          ],
        ),
        ),
      ),
    );
  }

Widget _buildDataListView() {
  // Calculate total price based on updated quantity
  ukupnaCijena = korpaList.fold(0.0, (sum, e) => sum + (e.ukupnaCijenaProizvoda ?? 0.0));

  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min, // Let the Column shrink to fit its children
      children: [
        ListView.builder(
          shrinkWrap: true, // Let the ListView take only as much height as needed
          physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling if the parent scrolls
          padding: const EdgeInsets.all(8.0),
          itemCount: korpaList.length,
          itemBuilder: (context, index) {
            final e = korpaList[index];
            return Column(
              children: [
                if (index == 0) _buildKupacRow(e),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: e.proizvod?.slika != null && e.proizvod!.slika!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.memory(
                                    base64Decode(e.proizvod!.slika!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.image, size: 20, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.proizvod?.naziv ?? 'Nema naziva',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (e.kolicina! > 1) {
                                        _updateQuantity(e, -1);
                                      }
                                    },
                                  ),
                                  Text(
                                    e.kolicina.toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _updateQuantity(e, 1);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Cijena: ${e.ukupnaCijenaProizvoda?.toStringAsFixed(2) ?? '0.00'} KM',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // Trashcan Icon on the right
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            // Do nothing on press
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ukupna cijena',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${ukupnaCijena.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



  Widget _buildKupacRow(Korpa e) {
    // Prikazujemo samo onaj ID koji nije null
    String kupacLabel = 'Kupac: ';
    if (e.klijentId != null) {
      kupacLabel += "${e.klijent!.ime!} ${e.klijent!.prezime}";
    } else if (e.zaposlenikId != null) {
      kupacLabel += "${e.zaposlenik!.ime!} ${e.zaposlenik!.prezime}";
    } else if (e.autoservisId != null) {
      kupacLabel += e.autoservis!.naziv!;
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


void _updateQuantity(Korpa e, int change) {
  setState(() {
    // Ensure kolicina is not null and doesn't go below 1
    if (e.kolicina != null && e.kolicina! + change >= 1) {
      e.kolicina = e.kolicina! + change; // Add change to kolicina

      // Check if discount is valid and apply accordingly
      if (e.proizvod?.popust != null && e.proizvod!.popust! > 0) {
        // Use price with discount if available
        e.ukupnaCijenaProizvoda = e.kolicina! * (e.proizvod?.cijenaSaPopustom ?? 0.0);
      } else {
        // Use regular price if no discount or popust is 0
        e.ukupnaCijenaProizvoda = e.kolicina! * (e.proizvod?.cijena ?? 0.0);
      }

      // Recalculate total price for the entire cart
      ukupnaCijena = korpaList.fold(0.0, (sum, item) => sum + (item.ukupnaCijenaProizvoda ?? 0.0));
    }
  });
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