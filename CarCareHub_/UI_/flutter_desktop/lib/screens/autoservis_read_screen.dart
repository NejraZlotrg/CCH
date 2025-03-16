import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/usluge.dart'; // Dodaj model za usluge
import 'package:flutter_mobile/models/zaposlenik.dart'; // Dodaj model za usluge
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart'; // Dodaj provider za usluge
import 'package:flutter_mobile/provider/zaposlenik_provider.dart'; // Dodaj provider za usluge
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/screens/autoservis_details_screen.dart';
import 'package:flutter_mobile/screens/autoservis_screen.dart';
import 'package:flutter_mobile/screens/chatAutoservisKlijentMessagesScreen.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:form_validation/form_validation.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AutoservisReadScreen extends StatefulWidget {
  Autoservis? autoservis;

  AutoservisReadScreen({super.key, this.autoservis});

  @override
  State<AutoservisReadScreen> createState() =>
      _AutoservisDetailsScreenState();
}

class _AutoservisDetailsScreenState extends State<AutoservisReadScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late AutoservisProvider _autoservisProvider;
  late UslugeProvider _uslugaProvider;
  late ZaposlenikProvider _zaposlenikProvider;

  late GradProvider _gradProvider;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  SearchResult<Grad>? gradResult;
  List<Usluge> usluge = [];
  List<Zaposlenik> zaposlenik = [];
  List<Grad> grad = [];
  SearchResult<Autoservis>? result;

  bool isLoading = true;

  final validator = CreateValidator();


  @override
  void initState() {
    super.initState();
    _initialValues = {
      'naziv': widget.autoservis?.naziv ?? '',
      'adresa': widget.autoservis?.adresa ?? '',
      'vlasnikFirme': widget.autoservis?.vlasnikFirme ?? '',
      'telefon': widget.autoservis?.telefon ?? '',
      'email': widget.autoservis?.email ?? '',
      'jib': widget.autoservis?.jib ?? '',
      'mbs': widget.autoservis?.mbs ?? '',
      'ulogaId': widget.autoservis?.ulogaId?.toString() ?? '',
      'gradId': widget.autoservis?.gradId ?? '',
      'username': widget.autoservis?.username,
      'password': widget.autoservis?.password ?? '',
      'passwordAgain': widget.autoservis?.passwordAgain ?? '',
      "slikaProfila": widget.autoservis?.slikaProfila ?? '',
      "slikaThumb": widget.autoservis?.slikaThumb ?? ''
    };

    _autoservisProvider = context.read<AutoservisProvider>();
    _uslugaProvider = context.read<UslugeProvider>();
    _gradProvider = context.read<GradProvider>();

    _zaposlenikProvider = context.read<ZaposlenikProvider>();



    initForm();
    fetchUsluge();
    fetchGrad();
 _fetchInitialData(); 
    fetchZaposlenik();
  }

  Future initForm() async {
     if (context.read<UserProvider>().role == "Admin") {
       gradResult = await _gradProvider.getAdmin();
     } else {
       gradResult = await _gradProvider.get();
     }
    if (widget.autoservis != null && widget.autoservis!.slikaProfila != null) {
      _imageFile =
          await _getImageFileFromBase64(widget.autoservis!.slikaProfila!);
    }
    setState(() {
      isLoading = false;
    });
  }
  Future<void> _fetchInitialData() async {
  setState(() {
    isLoading = true;
  });

  try {
    SearchResult<Autoservis> data;
    if (context.read<UserProvider>().role == "Admin") {
      data = await _autoservisProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
    } else {
      data = await _autoservisProvider.get(filter: {'IsAllIncluded': 'true'});
    }

    setState(() {
      result = data;
      // Pronađi i ažuriraj trenutni autoservis
      widget.autoservis = data.result.firstWhere(
        (a) => a.autoservisId == widget.autoservis?.autoservisId,
        orElse: () => widget.autoservis!,
      );
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška pri učitavanju podataka: $e')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  // Function to convert base64 image to File
  Future<File> _getImageFileFromBase64(String base64String) async {
    final bytes = base64Decode(base64String);
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchUsluge() async {
    try {
      usluge =
          await _uslugaProvider.getById(widget.autoservis?.autoservisId ?? 0);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Možete dodati logiku za rukovanje greškom ovdje, ako je potrebno.
        });
      }
    }
  }

  Future<void> fetchZaposlenik() async {
    try {
      if (widget.autoservis?.autoservisId != null) {
        zaposlenik = await _zaposlenikProvider
            .getzaposlenikById(widget.autoservis!.autoservisId!);
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Možete dodati logiku za rukovanje greškom ovdje, ako je potrebno.
        });
      }
    }
  }

  Future<void> fetchGrad() async {
   
      grad = await _gradProvider.getById(widget.autoservis?.gradId);
      if (grad.isNotEmpty && grad.first.vidljivo == false) {
      grad = []; // Postavi na praznu listu ako grad nije vidljiv
      _initialValues['gradId']; // Resetuj vrednost za dropdown
  
      if (mounted) {
        setState(() {});
      }
    }
   
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina

    appBar: AppBar(
      title: Text(widget.autoservis?.naziv ?? "Detalji autoservisa"),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildAutoservisDetails(),
                      const SizedBox(height: 20),
                      _buildUslugeList(), // Dodana sekcija za usluge
                      const SizedBox(height: 20),
                      _buildZaposlenikSection(),
                    ],
                  ),
                ),
              ),
              // Dugme "Uredi" na dnu
         Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    if (userProvider.role == "Admin" || (userProvider.role == "Autoservis" && userProvider.userId==widget.autoservis?.autoservisId)) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity, // Dugme preko cele širine
          child: ElevatedButton(
            onPressed: () {
              // Navigacija na ekran za uređivanje
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AutoservisDetailsScreen(
                    autoservis: widget.autoservis!,
                  ),
                ),
              ).then((_) {
                // Osvježi podatke nakon povratka s ekrana za uređivanje
                _fetchInitialData();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 245, 19, 3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15), // Veće dugme
            ),
            child: const Text(
              "Uredi",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  },
),

            ],
          ),
  );
}



Widget _buildZaposlenikSection() {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: zaposlenik.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Ime")),
                DataColumn(label: Text("Prezime")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Broj telefona")),
                DataColumn(label: Text("")),
              ],
              rows: zaposlenik.map((zap) {
                return DataRow(
                  cells: [
                    DataCell(Text(zap.ime ?? "")),
                    DataCell(Text(zap.prezime ?? "")),
                    DataCell(Text(zap.email ?? "")),
                    DataCell(Text(zap.brojTelefona?.toString() ?? "")),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          final klijentId = context.read<UserProvider>().userId;
                          final zaposleniId = zap.zaposlenikId!;
                          _showSendMessageDialog2(context, klijentId, zaposleniId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 248, 18, 2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat, size: 20),
                            SizedBox(width: 5),
                            Text("Pošaljite poruku"),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        : const Text("Nema dostupnih zaposlenika za ovaj autoservis."),
  );
}

 Widget _buildUslugeList() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: usluge.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Naziv usluge")),
                  DataColumn(label: Text("Cijena")),
                  DataColumn(label: Text("Opis")),
                ],
                rows: usluge.map((usluga) {
                  return DataRow(
                    cells: [
                      DataCell(Text(usluga.nazivUsluge ?? "")),
                      DataCell(Text(usluga.cijena?.toString() ?? "")),
                      DataCell(Text(usluga.opis ?? "")),
                    ],
                  );
                }).toList(),
              ),
            )
          : const Text("Nema dostupnih usluga za ovaj autoservis."),
    );
  }
Widget _buildAutoservisDetails() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center, // Centriranje slike i podataka
    children: [
      // Prva trećina - Povećana slika firme centrirana
      Expanded(
        flex: 1,
        child: Center(
          child: Container(
            width: 300, // Povećana širina slike
            height: 300, // Povećana visina slike
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _imageFile!,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 70, color: Colors.black), // Veća ikona
                      SizedBox(height: 15),
                      Text('Nema slike',
                          style: TextStyle(color: Colors.black, fontSize: 18)), // Veći tekst
                    ],
                  ),
          ),
        ),
      ),

      // Razmak između slike i podataka
      const SizedBox(width: 40), // Malo veći razmak za bolji balans

      // Druge dvije trećine - Podaci firme centrirani
    Expanded(
  flex: 2,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Red za dugme "Pošalji poruku"
      Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.role == "Klijent" || userProvider.role == "Admin") {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Align(
                alignment: Alignment.centerRight, // Poravnanje na desno
                child: ElevatedButton(
                  onPressed: () {
                    final klijentId = userProvider.userId;
                    final autoservisId = widget.autoservis!.autoservisId!;
                    _showSendMessageDialog(context, klijentId, autoservisId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 251, 25, 9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, size: 20),
                      SizedBox(width: 5),
                      Text("Pošalji poruku"),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),

      // Red za naziv autoservisa
      if (widget.autoservis?.naziv != null)
        Text(
          widget.autoservis!.naziv!,
          style: const TextStyle(
            fontSize: 28, // Malo veći naslov
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

      const SizedBox(height: 25), // Veći razmak ispod naslova

      // Tabela sa podacima
      DataTable(
        columnSpacing: 220, // Veći razmak između stupaca
        horizontalMargin: 10, // Horizontalni margine
        headingRowHeight: 0, // Sakrij zaglavlje
        dataRowHeight: 55, // Veći razmak između redova
        columns: const [
          DataColumn(label: SizedBox()), // Prazan zaglavni red
          DataColumn(label: SizedBox()),
        ],
        rows: [
          _buildDataRow("Vlasnik", widget.autoservis?.vlasnikFirme),
          _buildDataRow("Grad", widget.autoservis?.grad?.nazivGrada),
          _buildDataRow("Adresa", widget.autoservis?.adresa),
          _buildDataRow("Telefon", widget.autoservis?.telefon),
          _buildDataRow("Email", widget.autoservis?.email),
          _buildDataRow("JIB", widget.autoservis?.jib),
          _buildDataRow("MBS", widget.autoservis?.mbs),
        ],
      ),
    ],
  ),
),

    ],
  );
}

  void _showSendMessageDialog2(
      BuildContext context, int klijentId, int zaposleniId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message = "";
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Pošaljite poruku"),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    message = value; // Ažuriraj poruku kad se unese tekst
                  });
                },
                decoration: const InputDecoration(hintText: "Unesite poruku"),
              ),
              actions: [
                // Otkaži dugme
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Zatvori dijalog
                    }
                  },
                  child: const Text("Otkaži"),
                ),
                // Pošaljite dugme
                ElevatedButton(
                  onPressed: () async {
                    if (message.isNotEmpty) {
                      try {
                        // Poziv za slanje poruke
                        await Provider.of<ChatKlijentZaposlenikProvider>(
                          context,
                          listen: false,
                        ).sendMessage(klijentId, zaposleniId, message);

                        // Zatvori dijalog nakon slanja poruke
                        if (mounted && Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        // Obavijesti korisnika o uspjehu
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Poruka poslana uspješno")),
                        );
                      } catch (e) {
                        // Obavijesti korisnika o grešci
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Greška: ${e.toString()}")),
                          );
                        }
                      }
                    } else {
                      // Ako poruka nije uneta, obavesti korisnika
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Poruka ne može biti prazna")),
                      );
                    }
                  },
                  child: const Text("Pošaljite"),
                ),
              ],
            );
          },
        );
      },
    );
  }
// Funkcija za kreiranje jednog reda u tabeli s dodatnim razmakom
DataRow _buildDataRow(String label, String? value) {
  return DataRow(
    cells: [
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12), // Još veći razmak unutar ćelije
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12), // Još veći razmak unutar ćelije
          child: Text(value ?? 'Nema podataka', style: const TextStyle(fontSize: 16)),
        ),
      ),
    ],
  );
}

  void _showSendMessageDialog(
      BuildContext context, int klijentId, int autoservisId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message = "";
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Pošalji poruku"),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    message = value;
                  });
                },
                decoration: const InputDecoration(hintText: "Unesite poruku"),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Zatvori dialog
                    }
                  },
                  child: const Text("Otkaži"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Poziv za slanje poruke
                      await Provider.of<ChatAutoservisKlijentProvider>(
                        context,
                        listen: false,
                      ).sendMessage(klijentId, autoservisId, message);

                      if (mounted && Navigator.canPop(context)) {
                        Navigator.pop(context); // Zatvori dialog nakon slanja
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Poruka poslana uspješno")),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Greška: ${e.toString()}")),
                        );
                      }
                    }
                  },
                  child: const Text("Pošalji"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
