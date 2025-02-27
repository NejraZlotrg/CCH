import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
   
      grad = await _gradProvider.getById(widget.autoservis?.gradId ?? 0);
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
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Card with autoservis details
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Zaobljeni rubovi
                    ),
                    elevation: 5, // Sjena kartice
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Naziv autoservisa i dugme "Pošalji poruku"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Naziv autoservisa
                              Text(
                                widget.autoservis?.naziv ?? "Nema naziva",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Dugme "Pošalji poruku" (smaller size)
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  if (userProvider.role == "Klijent" || userProvider.role == "Admin") {
                                    return ElevatedButton(
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8, // Smaller vertical padding
                                          horizontal: 12, // Smaller horizontal padding
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.chat, size: 16), // Smaller icon
                                          SizedBox(width: 5),
                                          Text(
                                            "Pošalji poruku",
                                            style: TextStyle(fontSize: 14), // Smaller text
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20), // Razmak između naziva i adrese

                          // Adresa i grad sa ikonicom
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                "${widget.autoservis?.adresa ?? "Nema adrese"}, ${widget.autoservis?.grad?.nazivGrada ?? "Nema grada"}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15), // Razmak između adrese i telefona

                          // Telefon, JIB i MBS
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Telefon: ${widget.autoservis?.telefon ?? "Nema podataka"}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "JIB: ${widget.autoservis?.jib ?? "Nema podataka"}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "MBS: ${widget.autoservis?.mbs ?? "Nema podataka"}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20), // Razmak između podataka i tabele

                          // Tabela za zaposlenike
                          _buildZaposlenikSection(),

                          const SizedBox(height: 20), // Razmak između tabela

                          // Tabela za usluge
                          _buildUslugeList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Razmak između kartice i dugmeta

                  // Dugme "Uredi" na dnu (samo za Admina) - Outside the Card
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (userProvider.role == "Admin") {
                        return SizedBox(
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
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
  );
}

Widget _buildZaposlenikSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Zaposlenici",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.all(10),
        child: zaposlenik.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20, // Reduce spacing between columns
                    dataRowHeight: 40, // Smaller row height
                    headingRowHeight: 40, // Smaller heading row height
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Ime",
                          style: TextStyle(fontSize: 10), // Smaller font size
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Kontakt",
                          style: TextStyle(fontSize: 10), // Smaller font size
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "",
                          style: TextStyle(fontSize: 10), // Smaller font size
                        ),
                      ),
                    ],
                    rows: zaposlenik.map((zap) {
                      return DataRow(
                        cells: [
                          // Ime + Prezime
                          DataCell(
                            Text(
                              "${zap.ime ?? ""} ${zap.prezime ?? ""}",
                              style: const TextStyle(fontSize: 10), // Smaller font size
                            ),
                          ),
                          // Broj telefona
                          DataCell(
                            Text(
                              "0${zap.brojTelefona?.toString() ?? ""}",
                              style: const TextStyle(fontSize: 10), // Smaller font size
                            ),
                          ),
                          // Pošaljite poruku button
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3, // Smaller vertical padding
                                  horizontal: 5, // Smaller horizontal padding
                                ),
                                minimumSize: const Size(0, 36), // Smaller button height
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat, size: 10), // Smaller icon
                                  SizedBox(width: 5),
                                  Text(
                                    "Pošalji poruku",
                                    style: TextStyle(fontSize: 10), // Smaller text
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              )
            : const Text(
                "Nema dostupnih zaposlenika za ovaj autoservis.",
                style: TextStyle(fontSize: 14), // Smaller font size
              ),
      ),
    ],
  );
}


 Widget _buildUslugeList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Usluge",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.all(10),
        child: usluge.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20, // Reduced spacing between columns
                    dataRowHeight: 30, // Smaller row height
                    headingRowHeight: 30, // Smaller heading row height
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Naziv usluge",
                          style: TextStyle(fontSize: 10), // Font size 10
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Cijena",
                          style: TextStyle(fontSize: 10), // Font size 10
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Opis",
                          style: TextStyle(fontSize: 10), // Font size 10
                        ),
                      ),
                    ],
                    rows: usluge.map((usluga) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              usluga.nazivUsluge ?? "",
                              style: const TextStyle(fontSize: 10), // Font size 10
                            ),
                          ),
                          DataCell(
                            Text(
                              usluga.cijena?.toString() ?? "",
                              style: const TextStyle(fontSize: 10), // Font size 10
                            ),
                          ),
                          DataCell(
                            Text(
                              usluga.opis ?? "",
                              style: const TextStyle(fontSize: 10), // Font size 10
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              )
            : const Text(
                "Nema dostupnih usluga za ovaj autoservis.",
                style: TextStyle(fontSize: 10), // Font size 10
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
