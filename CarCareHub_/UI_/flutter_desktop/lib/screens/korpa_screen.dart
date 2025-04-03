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
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/screens/narudzba_screen.dart';
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
  late KlijentProvider _klijentProvider;
  late AutoservisProvider _autoservisProvider;
  late ZaposlenikProvider _zaposlenikProvider;
SearchResult<Product>? dataWithDiscount;
  late ProductProvider _productProvider;


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



    userId = _userProvider.userId;

    _loadData();
  }

  Future<void> _loadData() async {
  try {
    List<Korpa> data = await _korpaProvider.getById(userId);
 if(context.read<UserProvider>().role == "Autoservis")
    dataWithDiscount = await _productProvider.getForAutoservis( context.read<UserProvider>().userId, filter: {'IsAllIncluded': 'true'});
    
    setState(() {
      korpaList = data;

      // Calculate correct prices for each item
      for (var item in korpaList) {
        double pricePerItem;
        
        // 1. Check if user is Autoservis and product has special autoservis price
        if (_userProvider.role == "Autoservis" && 
            item.proizvod?.cijenaSaPopustomZaAutoservis != null && dataWithDiscount!.result.any((p) => p.proizvodId == item.proizvod?.proizvodId)) {
          pricePerItem = item.proizvod!.cijenaSaPopustomZaAutoservis!;
        } 
        // 2. Check if product has regular discount
        else if (item.proizvod?.popust != null && 
                 item.proizvod!.popust! > 0 && 
                 item.proizvod?.cijenaSaPopustom != null) {
          pricePerItem = item.proizvod!.cijenaSaPopustom!;
        }
        // 3. Default to regular price
        else {
          pricePerItem = item.proizvod?.cijena ?? 0.0;
        }

        item.ukupnaCijenaProizvoda = item.kolicina! * pricePerItem;
      }

      // Calculate total price
      ukupnaCijena = korpaList.fold(0.0, (sum, e) => sum + (e.ukupnaCijenaProizvoda ?? 0.0));
    });
  } catch (e) {
    print('Greška prilikom učitavanja podataka iz korpe: $e');
  }
}

Future<void> _finishOrder() async {
  try {
    // Ispis detalja o cijenama prije slanja
    print('╔═══════════════════════════════════════════════════');
    print('║ DETALJI O NARUDŽBI PRIJE SLAЊA');
    print('╠═══════════════════════════════════════════════════');
    print('║ UKUPNA CIJENA IZ KORPE: ${ukupnaCijena.toStringAsFixed(2)} KM');
    print('║');
    

    // Koristimo ukupnu cijenu koja je već izračunata u _loadData()
    // Nema potrebe za ponovnim računanjem jer je _loadData() već osigurala ispravne popuste
    double finalnaCijena = ukupnaCijena;

    if (_userProvider.role == 'Klijent') {
      var klijent = await _klijentProvider.getSingleById(_userProvider.userId);
     
      final narudzbaObjekat = {
        "klijentId": _userProvider.userId,
        "autoservisId": null,
        "ZaposlenikId": null,
        "zavrsenaNarudzba": true,
        "popustId": null,
        "ukupnaCijenaNarudzbe": finalnaCijena,  // Koristimo već izračunatu cijenu
        "adresa": klijent.adresa ?? "N/A",
      };

      await _narudzbaProvider.insert(narudzbaObjekat);
    }
    else if (_userProvider.role == 'Autoservis') {
      var autos = await _autoservisProvider.getSingleById(_userProvider.userId);
  


      final narudzbaObjekat = {
        "klijentId": null,
        "autoservisId": _userProvider.userId,
        "ZaposlenikId": null,
        "zavrsenaNarudzba": true,
        "popustId": null,
        "ukupnaCijenaNarudzbe": finalnaCijena,  // Koristimo već izračunatu cijenu
        "adresa": autos.adresa ?? "N/A",
      };

      await _narudzbaProvider.insert(narudzbaObjekat);
    }
    else if (_userProvider.role == 'Zaposlenik') {
      var zaposlenik = await _zaposlenikProvider.getSingleById(_userProvider.userId);
  
      final narudzbaObjekat = {
        "klijentId": null,
        "autoservisId": null,
        "ZaposlenikId": _userProvider.userId,
        "zavrsenaNarudzba": true,
        "popustId": null,
        "ukupnaCijenaNarudzbe": finalnaCijena,  // Koristimo već izračunatu cijenu
        "adresa": zaposlenik.adresa ?? "N/A",
      };
      
      print("Narudžba koja se šalje: ${jsonEncode(narudzbaObjekat)}");
      await _narudzbaProvider.insert(narudzbaObjekat);
    }

    // Očisti korpu nakon uspješne narudžbe
    await _korpaProvider.ocistiKorpu(
      klijentId: _userProvider.role == 'Klijent' ? _userProvider.userId : null,
      zaposlenikId: _userProvider.role == 'Zaposlenik' ? _userProvider.userId : null,
      autoservisId: _userProvider.role == 'Autoservis' ? _userProvider.userId : null,
    );

    // Prikaži poruku o uspjehu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Narudžba je uspješno kreirana.')),
    );

    // Navigiraj na ekran narudžbi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NarudzbaScreen()),
    );
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
  // Calculate total price based on updated quantity
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
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 140.0),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Slika proizvoda
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: e.proizvod?.slika != null && e.proizvod!.slika!.isNotEmpty
                                ? Image.memory(
                                    base64Decode(e.proizvod!.slika!),
                                    fit: BoxFit.cover,
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
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (e.kolicina != null && e.kolicina! > 1) {
                                          _updateQuantity(e, -1);
                                        }
                                      },
                                    ),
                                    Text(e.kolicina?.toString() ?? "0"),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        _updateQuantity(e, 1);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                // Prikaz cijena
                                _buildPriceDisplay(e, cijenaPoKomadu),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            iconSize: 40,
                            onPressed: () async {
                              await _korpaProvider.deleteProizvodIzKorpe(e.korpaId, e.proizvod?.proizvodId);
                              setState(() {
                                korpaList.removeAt(index);
                                ukupnaCijena = korpaList.fold(0.0, (sum, item) {
                                  return sum + (_calculateItemPrice(item) * (item.kolicina ?? 1));
                                });
                              });
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
          // Ukupna cijena
          Padding(
            padding: const EdgeInsets.only(left: 140.0, right: 140.0),
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

  // 1. Check if user is Autoservis, product has special price AND is in discount list
  if (_userProvider.role == "Autoservis" && 
      product.cijenaSaPopustomZaAutoservis != null &&
      (dataWithDiscount?.result?.any((p) => p.proizvodId == product.proizvodId) ?? false)) {
    return product.cijenaSaPopustomZaAutoservis!;
  }
  
  // 2. Check if product has regular discount
  if (product.popust != null && product.popust! > 0 && 
      product.cijenaSaPopustom != null) {
    return product.cijenaSaPopustom!;
  }
  
  // 3. Default to regular price
  return product.cijena ?? 0.0;
}
Widget _buildPriceDisplay(Korpa e, double currentPrice) {
  final product = e.proizvod;
  if (product == null) return const SizedBox();

  // Case 1: Autoservis with special price (only if product is in discount list)
  if (_userProvider.role == "Autoservis" && 
      product.cijenaSaPopustomZaAutoservis != null &&
      (dataWithDiscount?.result?.any((p) => p.proizvodId == product.proizvodId) ?? false)) {
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
  
  // Case 2: Regular discount for all users
  if (product.popust != null && product.popust! > 0 && 
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
  
  // Case 3: Regular price
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
        ukupnaCijena = korpaList.fold(0.0, (sum, item) => sum + (_calculateItemPrice(item) * (item.kolicina ?? 1)));
      });
    } else {
      print('Greška pri ažuriranju količine');
    }
  } catch (e) {
    print("Greška prilikom ažuriranja količine: $e");
  }
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
      visible: korpaList.isNotEmpty, // Prikazuje dugme samo ako korpa nije prazna
      child: ElevatedButton(
        onPressed: () async {
          // Show custom confirmation form
          bool confirmed = await _showCustomConfirmationForm(context);
          if (confirmed) {
            await _finishOrder();
            await _korpaProvider.ocistiKorpu(
              klijentId: _userProvider.role == 'Klijent' ? _userProvider.userId : null,
              zaposlenikId: _userProvider.role == 'Zaposlenik' ? _userProvider.userId : null,
              autoservisId: _userProvider.role == 'Autoservis' ? _userProvider.userId : null,
            );

            // // Osveži UI nakon čišćenja korpe
            // setState(() {
            //   korpaList.clear();
            //   ukupnaCijena = 0.0;
            // });
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          textStyle: const TextStyle(fontSize: 18),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white
        ),
        child: const Text('Završi narudžbu'),
      ),
    ),
  );
}

// Function to show custom confirmation form
Future<bool> _showCustomConfirmationForm(BuildContext context) async {
  bool confirmed = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Potvrda narudžbe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalji plaćanja i dostave:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Plaćanje:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Plaćanje će biti izvršeno gotovinom prilikom preuzimanja.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Dostava:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Narudžba će biti poslana brzom poštom.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Otkaži'),
                ),
                ElevatedButton(
                  onPressed: () {
                    confirmed = true;
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Potvrdi'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  return confirmed;
}

}