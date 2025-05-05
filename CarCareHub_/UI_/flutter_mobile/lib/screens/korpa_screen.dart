// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/screens/narudzba_screen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/models/placanje_insert.dart';
import 'package:flutter_mobile/models/rezultat_placanja.dart';
import 'package:flutter_mobile/provider/placanje_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    show Address, BillingDetails, SetupPaymentSheetParameters, Stripe;

class KorpaScreen extends StatefulWidget {
  const KorpaScreen({super.key});

  @override
  State<KorpaScreen> createState() => _KorpaScreenState();
}

class _KorpaScreenState extends State<KorpaScreen> {
  late KorpaProvider _korpaProvider;
  late NarudzbaProvider _narudzbaProvider;
  late UserProvider _userProvider;
  late KlijentProvider _klijentProvider;
  late AutoservisProvider _autoservisProvider;
  late ZaposlenikProvider _zaposlenikProvider;
  SearchResult<Product>? dataWithDiscount;
  late ProductProvider _productProvider;
  late PlacanjeProvider _placanjeProvider;

  List<Korpa> korpaList = [];
  late int userId;
  late double ukupnaCijena;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korpaProvider = context.read<KorpaProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _userProvider = context.read<UserProvider>();
    _klijentProvider = context.read<KlijentProvider>();
    _autoservisProvider = context.read<AutoservisProvider>();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _productProvider = context.read<ProductProvider>();
    _placanjeProvider = context.read<PlacanjeProvider>();

    userId = _userProvider.userId;

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Korpa> data = await _korpaProvider.getById(userId);
      if (context.read<UserProvider>().role == "Autoservis") {
        dataWithDiscount = await _productProvider.getForAutoservis(
            context.read<UserProvider>().userId,
            filter: {'IsAllIncluded': 'true'});
      }

      setState(() {
        korpaList = data;

        for (var item in korpaList) {
          double pricePerItem = _calculateItemPrice(item);
          item.ukupnaCijenaProizvoda = item.kolicina! * pricePerItem;
        }

        ukupnaCijena = korpaList.fold(
            0.0, (sum, e) => sum + (e.ukupnaCijenaProizvoda ?? 0.0));
      });
    } catch (e) {
      print('Greška prilikom učitavanja podataka iz korpe: $e');
    }
  }

  Future<void> _finishOrder() async {
    try {
      double finalnaCijena = ukupnaCijena;

      late dynamic narudzbaObjekat;
      String adresa = "N/A";

      if (_userProvider.role == 'Klijent') {
        var klijent =
            await _klijentProvider.getSingleById(_userProvider.userId);
        adresa = klijent.adresa ?? "N/A";
        narudzbaObjekat = {
          "klijentId": _userProvider.userId,
          "autoservisId": null,
          "ZaposlenikId": null,
          "zavrsenaNarudzba": true,
          "popustId": null,
          "ukupnaCijenaNarudzbe": finalnaCijena,
          "adresa": adresa,
        };
      } else if (_userProvider.role == 'Autoservis') {
        var autos =
            await _autoservisProvider.getSingleById(_userProvider.userId);
        adresa = autos.adresa ?? "N/A";
        narudzbaObjekat = {
          "klijentId": null,
          "autoservisId": _userProvider.userId,
          "ZaposlenikId": null,
          "zavrsenaNarudzba": true,
          "popustId": null,
          "ukupnaCijenaNarudzbe": finalnaCijena,
          "adresa": adresa,
        };
      } else if (_userProvider.role == 'Zaposlenik') {
        var zaposlenik =
            await _zaposlenikProvider.getSingleById(_userProvider.userId);
        adresa = zaposlenik.adresa ?? "N/A";
        narudzbaObjekat = {
          "klijentId": null,
          "autoservisId": null,
          "ZaposlenikId": _userProvider.userId,
          "zavrsenaNarudzba": true,
          "popustId": null,
          "ukupnaCijenaNarudzbe": finalnaCijena,
          "adresa": adresa,
        };
      }

      await _handlePayment(narudzbaObjekat);
    } catch (e) {
      print('Greška prilikom kreiranja narudžbe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška prilikom kreiranja narudžbe.')),
      );
    }
  }

  Future<void> _handlePayment(dynamic narudzba) async {
    try {
      double ukupno = narudzba['ukupnaCijenaNarudzbe'] * 100;

      RezultatPlacanja paymentResult =
          await _placanjeProvider.create(PlacanjeInsert(ukupno: ukupno));

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResult.clientSecret,
          merchantDisplayName: 'CarCareHub',
          billingDetails: BillingDetails(
            address: Address(
              city: narudzba['adresa']?.split(',')?.last.trim() ?? 'Mostar',
              country: 'BA',
              line1: narudzba['adresa'] ?? '',
              line2: '',
              postalCode: '',
              state: '',
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _narudzbaProvider.insert(narudzba);

      await _korpaProvider.ocistiKorpu(
        klijentId:
            _userProvider.role == 'Klijent' ? _userProvider.userId : null,
        zaposlenikId:
            _userProvider.role == 'Zaposlenik' ? _userProvider.userId : null,
        autoservisId:
            _userProvider.role == 'Autoservis' ? _userProvider.userId : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narudžba je uspješno kreirana.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NarudzbaScreen()),
      );
    } catch (e) {
      print('Greška prilikom plaćanja: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom plaćanja: ${e.toString()}')),
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
    ukupnaCijena = korpaList.fold(0.0, (sum, e) {
      double cijena = _calculateItemPrice(e);
      return sum + (cijena * (e.kolicina ?? 1));
    });

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemCount: korpaList.length,
              itemBuilder: (context, index) {
                final e = korpaList[index];
                final cijenaPoKomadu = _calculateItemPrice(e);

                return Column(
                  children: [
                    if (index == 0) _buildKupacRow(e),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      elevation: 3.0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: e.proizvod?.slika != null &&
                                          e.proizvod!.slika!.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(e.proizvod!.slika!),
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(
                                          child: Icon(Icons.image,
                                              size: 20, color: Colors.grey),
                                        ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.proizvod?.naziv ?? 'Nema naziva',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 20),
                                            onPressed: () {
                                              if (e.kolicina != null &&
                                                  e.kolicina! > 1) {
                                                _updateQuantity(e, -1);
                                              }
                                            },
                                          ),
                                          Text(e.kolicina?.toString() ?? "0"),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.add, size: 20),
                                            onPressed: () {
                                              _updateQuantity(e, 1);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  iconSize: 28,
                                  onPressed: () async {
                                    await _korpaProvider.deleteProizvodIzKorpe(
                                        e.korpaId, e.proizvod?.proizvodId);
                                    setState(() {
                                      korpaList.removeAt(index);
                                      ukupnaCijena =
                                          korpaList.fold(0.0, (sum, item) {
                                        return sum +
                                            (_calculateItemPrice(item) *
                                                (item.kolicina ?? 1));
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            _buildPriceDisplay(e, cijenaPoKomadu),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      ),
    );
  }

  double _calculateItemPrice(Korpa item) {
    final product = item.proizvod;
    if (product == null) return 0.0;

    if (_userProvider.role == "Autoservis" &&
        product.cijenaSaPopustomZaAutoservis != null &&
        (dataWithDiscount?.result
                .any((p) => p.proizvodId == product.proizvodId) ??
            false)) {
      return product.cijenaSaPopustomZaAutoservis!;
    }

    if (product.popust != null &&
        product.popust! > 0 &&
        product.cijenaSaPopustom != null) {
      return product.cijenaSaPopustom!;
    }

    return product.cijena ?? 0.0;
  }

  Widget _buildPriceDisplay(Korpa e, double currentPrice) {
    final product = e.proizvod;
    if (product == null) return const SizedBox();

    if (_userProvider.role == "Autoservis" &&
        product.cijenaSaPopustomZaAutoservis != null &&
        (dataWithDiscount?.result
                .any((p) => p.proizvodId == product.proizvodId) ??
            false)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.cijena != null)
            Text(
              "Cijena: ${product.cijena} KM",
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          Text(
            "Cijena za autoservis: ${currentPrice.toStringAsFixed(2)} KM",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
          Text(
            "Ukupno: ${(currentPrice * (e.kolicina ?? 1)).toStringAsFixed(2)} KM",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    if (product.popust != null &&
        product.popust! > 0 &&
        product.cijenaSaPopustom != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.cijena != null)
            Text(
              "Cijena: ${product.cijena} KM",
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          Text(
            "Cijena sa popustom: ${currentPrice.toStringAsFixed(2)} KM",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          Text(
            "Ukupno: ${(currentPrice * (e.kolicina ?? 1)).toStringAsFixed(2)} KM",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cijena: ${currentPrice.toStringAsFixed(2)} KM",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          "Ukupno: ${(currentPrice * (e.kolicina ?? 1)).toStringAsFixed(2)} KM",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _updateQuantity(Korpa e, int change) async {
    int novaKolicina = (e.kolicina ?? 0) + change;

    if (novaKolicina < 1) {
      print('Količina ne može biti manja od 1.');
      return;
    }

    try {
      bool uspesno = await _korpaProvider.updateKolicina(
        e.korpaId,
        e.proizvod?.proizvodId,
        novaKolicina,
      );

      if (uspesno) {
        setState(() {
          e.kolicina = novaKolicina;
          e.ukupnaCijenaProizvoda = _calculateItemPrice(e) * novaKolicina;
          ukupnaCijena = korpaList.fold(
              0.0,
              (sum, item) =>
                  sum + (_calculateItemPrice(item) * (item.kolicina ?? 1)));
        });
      } else {
        print('Greška pri ažuriranju količine');
      }
    } catch (e) {
      print("Greška prilikom ažuriranja količine: $e");
    }
  }

  Widget _buildKupacRow(Korpa e) {
    String kupacLabel = 'Kupac: ';
    if (e.klijentId != null) {
      kupacLabel += "${e.klijent!.ime!} ${e.klijent!.prezime}";
    } else if (e.zaposlenikId != null) {
      kupacLabel += "${e.zaposlenik!.ime!} ${e.zaposlenik!.prezime}";
    } else if (e.autoservisId != null) {
      kupacLabel += e.autoservis!.naziv!;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            kupacLabel,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Visibility(
        visible: korpaList.isNotEmpty,
        child: ElevatedButton(
          onPressed: () async {
            await _finishOrder();
          },
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
            textStyle: const TextStyle(fontSize: 18),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Završi narudžbu'),
        ),
      ),
    );
  }
}
