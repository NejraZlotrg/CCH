import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/korpa.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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

  List<Korpa> korpaList = [];
  late int userId;
  late double ukupnaCijena;

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

      // Osiguraj da je ukupnaCijenaProizvoda postavljena
      for (var item in korpaList) {
        if (item.ukupnaCijenaProizvoda == null) {
          item.ukupnaCijenaProizvoda = item.kolicina! *
              (item.proizvod?.popust != null && item.proizvod!.popust! > 0
                  ? (item.proizvod?.cijenaSaPopustom ?? 0.0)
                  : (item.proizvod?.cijena ?? 0.0));
        }
      }

      // Ponovno izračunavanje ukupne cijene
      ukupnaCijena = korpaList.fold(0.0, (sum, e) => sum + (e.ukupnaCijenaProizvoda ?? 0.0));
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
       "ukupnaCijenaNarudzbe":ukupnaCijena
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
        "ukupnaCijenaNarudzbe":ukupnaCijena

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
        "ukupnaCijenaNarudzbe":ukupnaCijena

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
         // Navigacija na ekran narudžbi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NarudzbaScreen()),
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 140.0),
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
                          width: 100,
                          height: 100,
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
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
  children: [
    IconButton(
      icon: const Icon(Icons.remove),
      onPressed: () async {
        if (e.kolicina != null && e.kolicina! > 1) {
          _updateQuantity(e, -1);
          
        //  _korpaProvider.updateKolicina(e.korpaId, e.proizvod?.proizvodId, int.parse(e.kolicina.toString()));

          setState(() {}); // Osvežavanje UI-ja
        }
      },
    ),
    Text(
      e.kolicina?.toString() ?? "0", // Prikaz količine, sigurnost od null-a
      style: const TextStyle(fontSize: 14),
    ),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        _updateQuantity(e, 1);
     ///   _korpaProvider.updateKolicina(e.korpaId, e.proizvod?.proizvodId, int.parse(e.kolicina.toString()));

        setState(() {}); // Osvežavanje UI-ja
      },
    ),
  ],
)
,
                             const SizedBox(height: 8.0),
Text(
  'Cijena: ${e.kolicina! * (e.proizvod?.popust != null && e.proizvod!.popust! > 0 
    ? (e.proizvod?.cijenaSaPopustom ?? 0.0) 
    : (e.proizvod?.cijena ?? 0.0))} KM',
  style: const TextStyle(fontSize: 14),
),

                            ],
                          ),
                        ),
                     IconButton(
  icon: const Icon(Icons.delete_outline),
  iconSize: 40,
  onPressed: () async {
    try {
      await _korpaProvider.deleteProizvodIzKorpe(e.korpaId, e.proizvod?.proizvodId); // Poziv API-ja za brisanje
      setState(() {
        // Ažuriraj UI nakon brisanja (ako koristiš StatefulWidget)
        korpaList.removeWhere((item) => item.proizvodId == e.proizvod?.proizvodId && item.korpaId==e.korpaId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proizvod uspešno obrisan")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška prilikom brisanja: $e")),
      );
    }
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
        // Add 100px padding on left and right for the "Ukupna cijena" row
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
  );
}
void _updateQuantity(Korpa e, int change) async {
  int novaKolicina = (e.kolicina! ) + change;

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

        if (e.proizvod?.popust != null && e.proizvod!.popust! > 0) {
          e.ukupnaCijenaProizvoda = e.kolicina! * (e.proizvod?.cijenaSaPopustom ?? 0.0);
        } else {
          e.ukupnaCijenaProizvoda = e.kolicina! * (e.proizvod?.cijena ?? 0.0);
        }

        ukupnaCijena = korpaList.fold(0.0, (sum, item) => sum + (item.ukupnaCijenaProizvoda ?? 0.0));

        print("Nova količina: $novaKolicina"); // Ispis u terminal
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
          await _finishOrder();
          await _korpaProvider.ocistiKorpu(
            klijentId: _userProvider.role == 'Klijent' ? _userProvider.userId : null,
            zaposlenikId: _userProvider.role == 'Zaposlenik' ? _userProvider.userId : null,
            autoservisId: _userProvider.role == 'Autoservis' ? _userProvider.userId : null,
          );

          // Osveži UI nakon čišćenja korpe
          setState(() {
            korpaList.clear();
            ukupnaCijena = 0.0;
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Završi narudžbu'),
      ),
    ),
  );
}

}
