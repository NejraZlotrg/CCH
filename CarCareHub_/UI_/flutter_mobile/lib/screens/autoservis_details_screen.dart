import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/usluge.dart'; // Dodaj model za usluge
import 'package:flutter_mobile/models/zaposlenik.dart'; // Dodaj model za usluge
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart'; // Dodaj provider za usluge
import 'package:flutter_mobile/provider/zaposlenik_provider.dart'; // Dodaj provider za usluge
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/screens/chatAutoservisKlijentMessagesScreen.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AutoservisDetailsScreen extends StatefulWidget {
  Autoservis? autoservis;

  AutoservisDetailsScreen({super.key, this.autoservis});

  @override
  State<AutoservisDetailsScreen> createState() => _AutoservisDetailsScreenState();
}

class _AutoservisDetailsScreenState extends State<AutoservisDetailsScreen> {
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


  bool isLoading = true;

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
      'gradId': widget.autoservis?.gradId,
      'username': widget.autoservis?.username,
      'password': widget.autoservis?.password,
      'passwordAgain': widget.autoservis?.passwordAgain,
      "slikaProfila": widget.autoservis?.slikaProfila
    };

    _autoservisProvider = context.read<AutoservisProvider>();
    _uslugaProvider = context.read<UslugeProvider>(); 
    _gradProvider = context.read<GradProvider>(); 

    _zaposlenikProvider = context.read<ZaposlenikProvider>(); 

    _gradProvider = context.read<GradProvider>();
    
    initForm();
    fetchUsluge(); 
    fetchGrad(); 

    fetchZaposlenik(); 

  }

  Future initForm() async {
    gradResult = await _gradProvider.get();
    if (widget.autoservis != null && widget.autoservis!.slikaProfila != null) {
      _imageFile = await _getImageFileFromBase64(widget.autoservis!.slikaProfila!);
    }
    setState(() {
      isLoading = false;
    });
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
    usluge = await _uslugaProvider.getById(widget.autoservis?.autoservisId ?? 0);
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
      zaposlenik = await _zaposlenikProvider.getzaposlenikById(widget.autoservis!.autoservisId!);
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
  try {
    grad = await _gradProvider.getById(widget.autoservis?.gradId ?? 0);
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
                  const SizedBox(height: 20),
                  _buildForm(),
                  Padding(
  padding: const EdgeInsets.all(10),
  child: usluge.isNotEmpty
      ? Container(
          decoration: BoxDecoration(
            color: Colors.white, // Bela pozadina
            border: Border.all(color: Colors.grey, width: 1), // Sivi okvir
            borderRadius: BorderRadius.circular(10), // Zaobljeni uglovi
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
                  ),
                  // Dugme za dodavanje usluge
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
  onPressed: () => _showAddUslugaDialog(),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // Crvena boja dugmeta
    foregroundColor: Colors.white, // Bijela boja teksta
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
  child: const Text("Dodaj uslugu"),
),

                  ),
                  // Prikaz zaposlenika
                  Padding(
  padding: const EdgeInsets.all(10),
  child: zaposlenik.isNotEmpty
      ? Container(
          decoration: BoxDecoration(
            color: Colors.white, // Bela pozadina
            border: Border.all(color: Colors.grey, width: 1), // Sivi okvir
            borderRadius: BorderRadius.circular(10), // Zaobljeni uglovi
          ),
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Ime")),
              DataColumn(label: Text("Prezime")),
              DataColumn(label: Text("Email")),
              DataColumn(label: Text("Broj telefona")),
            ],
            rows: zaposlenik.map((zap) {
              return DataRow(
                cells: [
                  DataCell(Text(zap.ime ?? "")),
                  DataCell(Text(zap.prezime ?? "")),
                  DataCell(Text(zap.email ?? "")),
                  DataCell(Text(zap.brojTelefona?.toString() ?? "")),
                ],
              );
            }).toList(),
          ),
        )
      : const Text("Nema dostupnih zaposlenika za ovaj autoservis."),
)
,
                  // Dugme za dodavanje zaposlenika
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () => _showAddZaposlenikDialog(),  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // Crvena boja dugmeta
    foregroundColor: Colors.white, // Bijela boja teksta
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
                      child: const Text("Dodaj zaposlenika"),
                    ),
                  ),
                  // Spremanje podataka
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ?? false) {
                              var request = Map.from(_formKey.currentState!.value);
                              request['ulogaId'] = 3;

                              // Dodaj sliku u request
                              if (_imageFile != null) {
                                final imageBytes = await _imageFile!.readAsBytes();
                                request['slikaProfila'] = base64Encode(imageBytes);
                              }

                              try {
                                if (widget.autoservis == null) {
                                  await _autoservisProvider.insert(request);
                                } else {
                                  await _autoservisProvider.update(
                                      widget.autoservis!.autoservisId!, request);
                                }
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              } on Exception catch (e) {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Greška"),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      )
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Spasi"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
  );
}

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValues,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Align(
  alignment: Alignment.centerRight, // Poravnanje na desnu stranu
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    // Provjera da li je korisnik klijent
    if (userProvider.role == "Klijent") {
      return ElevatedButton(
        onPressed: () {
          final klijentId = userProvider.userId; // Dohvati ID logiranog klijenta
          final autoservisId = widget.autoservis!.autoservisId!;

          // Prikaži popup za unos poruke
          _showSendMessageDialog(context, klijentId, autoservisId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat, size: 20), // Ikona chata
            SizedBox(width: 5), // Razmak između ikone i teksta
            Text("Pošalji poruku"),
          ],
        ),
      );
    } else {
      return const SizedBox(); // Prazan widget ako korisnik nije klijent
    }
  },
)

  ),
),


          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 250,
                height: 250,
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
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Icon(Icons.camera_alt,
                        size: 60, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._buildFormFields(),
        ],
      ),
    );
  }


 List<Widget> _buildFormFields() {
    return [
      // Osnovni podaci
      Row(
        children: [
          Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Naziv autoservisa",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "naziv",
              ),
            ),
                  const SizedBox(width: 20),
            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Vlasnik autoservisa",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "vlasnikFirme",
              ),
            ),
          ],
        ),
    const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Adresa",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "adresa",
              ),
            ),
                  const SizedBox(width: 20),
            Expanded(
              child: FormBuilderDropdown(
                name: 'gradId',
                decoration: const InputDecoration(
                labelText: 'Grad',
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                hintText: 'Izaberite grad',
              ),
                initialValue: widget.autoservis?.gradId != null
                    ? widget.autoservis!.gradId.toString()
                    : null,
                items: gradResult?.result
                        .map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: item.gradId.toString(),
                              child: Text(item.nazivGrada ?? ""),
                            ))
                        .toList() ??
                    [],
              ),
            ),
          ],
        ),
    const SizedBox(height: 20),
       
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Telefon",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "telefon",
              ),
            ),
                  const SizedBox(width: 20),

            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "email",
              ),
            ),
          ],
        ),
    const SizedBox(height: 20),
       
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "JIB",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "jib",
              ),
            ),
                  const SizedBox(width: 20),

            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "MBS",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "mbs",
              ),
            ),
          ],
        ),
    const SizedBox(height: 20),
   
       Row(
          children: [
         
            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Korosničko ime",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "username",
                initialValue: widget.autoservis?.username,
              ),
            ),
          ],
        ),
    const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Lozinka",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "password",
                obscureText: true,
                initialValue: widget.autoservis?.password,
              ),
            ),
                  const SizedBox(width: 20),

            Expanded(
              child: FormBuilderTextField(
                decoration: const InputDecoration(
                labelText: "Ponovite lozinku",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
                name: "passwordAgain",
                obscureText: true,
                initialValue: widget.autoservis?.passwordAgain,
              ),
            ),
          ],
    ),
      const SizedBox(height: 20),
     
    ];
  }



  // Dijalog za dodavanje nove usluge
  void _showAddUslugaDialog() {
    final uslugaFormKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Dodaj novu uslugu"),
          content: FormBuilder(
            key: uslugaFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: "nazivUsluge",
                  decoration: const InputDecoration(labelText: "Naziv usluge"),
                ),
                FormBuilderTextField(
                  name: "cijena",
                  decoration: const InputDecoration(labelText: "Cijena"),
                  keyboardType: TextInputType.number,
                ),
                FormBuilderTextField(
                  name: "opis",
                  decoration: const InputDecoration(labelText: "Opis"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Odustani"),
            ),
            TextButton(
              onPressed: () async {
                uslugaFormKey.currentState?.saveAndValidate();
                var uslugaRequest = Map.from(uslugaFormKey.currentState!.value);
                uslugaRequest['autoservisId'] = widget.autoservis?.autoservisId;

                try {
                  await _uslugaProvider.insert(uslugaRequest);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  fetchUsluge(); // Osvježi usluge nakon dodavanja nove
                } on Exception catch (e) {
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Greška"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text("Dodaj"),
            ),
          ],
        );
      },
    );
  }
void _showAddZaposlenikDialog() {
  final zaposlenikFormKey = GlobalKey<FormBuilderState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Dodaj novog zaposlenika"),
        content: SingleChildScrollView(
          child: FormBuilder(
            key: zaposlenikFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: "ime",
                  decoration: const InputDecoration(labelText: "Ime"),
                ),
                FormBuilderTextField(
                  name: "prezime",
                  decoration: const InputDecoration(labelText: "Prezime"),
                ),
                FormBuilderTextField(
                  name: "maticniBroj",
                  decoration: const InputDecoration(labelText: "Matični broj"),
                  keyboardType: TextInputType.number,
                ),
                FormBuilderTextField(
                  name: "brojTelefona",
                  decoration: const InputDecoration(labelText: "Broj telefona"),
                  keyboardType: TextInputType.phone,
                ),
                   FormBuilderDateTimePicker(
  name: "datumRodjenja",
  inputType: InputType.date,
  decoration: const InputDecoration(
    labelText: "Datum Rođenja",
  ),
  format: DateFormat("dd.MM.yyyy"),
  initialValue: _initialValues['datumRodjenja'], // Povezuje inicijalnu vrednost
),
                FormBuilderTextField(
                  name: "email",
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                FormBuilderTextField(
                  name: "username",
                  decoration: const InputDecoration(labelText: "Korisničko ime"),
                ),
                FormBuilderTextField(
                  name: "password",
                  decoration: const InputDecoration(labelText: "Lozinka"),
                  obscureText: true,
                ),
                FormBuilderTextField(
                  name: "passwordAgain",
                  decoration: const InputDecoration(labelText: "Ponovi lozinku"),
                  obscureText: true,
                ),
             
                FormBuilderDropdown(
                name: 'gradId',
                decoration: InputDecoration(
                  labelText: 'Grad',
                  suffix: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _formKey.currentState!.fields['gradId']?.reset();
                    },
                  ),
                  hintText: 'grad',
                ),
                initialValue: widget.autoservis?.gradId != null
                    ? widget.autoservis!.gradId.toString()
                    : null,
                items: gradResult?.result
                        .map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: item.gradId.toString(),
                              child: Text(item.nazivGrada ?? ""),
                            ))
                        .toList() ??
                    [],
              ),
               
             
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Odustani"),
          ),
          TextButton(
            onPressed: () async {
              zaposlenikFormKey.currentState?.saveAndValidate();
              var zaposlenikRequest =
                  Map<String, dynamic>.from(zaposlenikFormKey.currentState!.value);

                  
// Pretvorite datum u odgovarajući format (npr. ISO 8601)
if (zaposlenikRequest['datumRodjenja'] != null) {
  zaposlenikRequest['datumRodjenja'] = (zaposlenikRequest['datumRodjenja'] as DateTime).toIso8601String();
}

   zaposlenikRequest['ulogaId'] = 1;

              // Dodaj autoservisId prije slanja na server
              zaposlenikRequest['autoservisId'] = widget.autoservis?.autoservisId;

              try {
                await _zaposlenikProvider.insert(zaposlenikRequest);
                Navigator.pop(context);
                fetchZaposlenik(); // Osvježi listu zaposlenika nakon dodavanja
              } catch (e) {
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("Greška"),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text("Dodaj"),
          ),
        ],
      );
    },
  );
}
void _showSendMessageDialog(BuildContext context, int klijentId, int autoservisId) {
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
                      const SnackBar(content: Text("Poruka poslana uspješno")),
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