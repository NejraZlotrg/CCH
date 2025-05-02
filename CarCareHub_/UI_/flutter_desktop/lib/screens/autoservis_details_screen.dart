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
import 'package:flutter_mobile/screens/autoservis_screen.dart';
import 'package:flutter_mobile/screens/chatAutoservisKlijentMessagesScreen.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_validation/form_validation.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AutoservisDetailsScreen extends StatefulWidget {
  Autoservis? autoservis;

  AutoservisDetailsScreen({super.key, this.autoservis});

  @override
  State<AutoservisDetailsScreen> createState() =>
      _AutoservisDetailsScreenState();
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
  bool _usernameExists = false;
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
      "vidljivo": widget.autoservis?.vidljivo
    };

    _autoservisProvider = context.read<AutoservisProvider>();
    _uslugaProvider = context.read<UslugeProvider>();
    _gradProvider = context.read<GradProvider>();

    _zaposlenikProvider = context.read<ZaposlenikProvider>();

    initForm();
    fetchUsluge();
    fetchGrad();

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
        setState(() {});
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
        setState(() {});
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
      backgroundColor:
          const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
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
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text("Naziv usluge")),
                                  DataColumn(label: Text("Cijena")),
                                  DataColumn(label: Text("Opis")),
                                  DataColumn(label: Text("Uredi")),
                                  DataColumn(label: Text("Obriši")),
                                ],
                                rows: usluge.map((usluga) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(usluga.nazivUsluge ?? "")),
                                      DataCell(Text(
                                          usluga.cijena?.toString() ?? "")),
                                      DataCell(Text(usluga.opis ?? "")),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () => _editUsluga(usluga),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteUsluga(usluga),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            )
                          : const Text(
                              "Nema dostupnih usluga za ovaj autoservis."),
                    ),
                    // Dugme za dodavanje usluge
                    if (context.read<UserProvider>().role == "Admin" ||
                        (context.read<UserProvider>().role == "Autoservis" &&
                            context.read<UserProvider>().userId ==
                                widget.autoservis?.autoservisId))
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () => _showAddUslugaDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 251, 26, 10), // Crvena boja dugmeta
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
                                border: Border.all(
                                    color: Colors.grey, width: 1), // Sivi okvir
                                borderRadius: BorderRadius.circular(
                                    10), // Zaobljeni uglovi
                              ),
                              child: Column(
                                children: [
                                  DataTable(
                                    columns: [
                                      const DataColumn(label: Text("Ime")),
                                      const DataColumn(label: Text("Prezime")),
                                      const DataColumn(label: Text("Email")),
                                      const DataColumn(
                                          label: Text("Broj telefona")),
                                      const DataColumn(label: Text("Uredi")),
                                      const DataColumn(label: Text("Obriši")),
                                      if (context.read<UserProvider>().role ==
                                          "Klijent")
                                        const DataColumn(
                                            label: Text(
                                                "")), // Empty header for message button
                                    ],
                                    rows: zaposlenik.map((zap) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(zap.ime ?? "")),
                                          DataCell(Text(zap.prezime ?? "")),
                                          DataCell(Text(zap.email ?? "")),
                                          DataCell(Text(
                                              zap.brojTelefona?.toString() ??
                                                  "")),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () =>
                                                  _editZaposlenik(zap),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _deleteZaposlenik(zap),
                                            ),
                                          ),
                                          if (context
                                                  .read<UserProvider>()
                                                  .role ==
                                              "Klijent")
                                            DataCell(
                                              ElevatedButton(
                                                onPressed: () {
                                                  final klijentId = context
                                                      .read<UserProvider>()
                                                      .userId;
                                                  final zaposleniId =
                                                      zap.zaposlenikId!;
                                                  _showSendMessageDialog2(
                                                      context,
                                                      klijentId,
                                                      zaposleniId);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 247, 28, 13),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                ],
                              ),
                            )
                          : const Text(
                              "Nema dostupnih zaposlenika za ovaj autoservis."),
                    ),
                    if (context.read<UserProvider>().role == "Admin" ||
                        (context.read<UserProvider>().role == "Autoservis" &&
                            context.read<UserProvider>().userId ==
                                widget.autoservis
                                    ?.autoservisId)) // Dugme za dodavanje zaposlenika
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () => _showAddZaposlenikDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 253, 27, 11), // Crvena boja dugmeta
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
                        if (context.read<UserProvider>().role == "Admin" ||
                            (context.read<UserProvider>().role ==
                                    "Autoservis" &&
                                context.read<UserProvider>().userId ==
                                    widget.autoservis?.autoservisId))
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Potvrda brisanja
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Potvrda brisanja"),
                                    content: const Text(
                                        "Da li ste sigurni da želite izbrisati ovaj proizvod?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Otkaži"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Izbriši"),
                                      ),
                                    ],
                                  ),
                                );

                                // Ako korisnik potvrdi brisanje
                                if (confirmDelete == true) {
                                  try {
                                    await _autoservisProvider.delete(
                                        widget.autoservis!.autoservisId!);
                                    Navigator.pop(
                                        context); // Vrati se na prethodni ekran
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Proizvod uspješno izbrisan."),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Greška prilikom brisanja: ${e.toString()}"),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(255, 249,
                                    11, 11), // Crvena boja za brisanje
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Izbriši"),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () async {
      // Provjera validacije forme
      if (!(_formKey.currentState?.validate() ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Molimo popunite obavezna polja."),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Provjera username-a
      final username = _formKey.currentState?.fields['username']?.value;
      if (username != null && username.toString().isNotEmpty) {
        final exists = await _autoservisProvider.checkUsernameExists(username);
        if (exists && (widget.autoservis == null || 
            widget.autoservis?.username?.toLowerCase() != username.toLowerCase())) {
          setState(() {
            _usernameExists = true;
          });
          _formKey.currentState?.fields['username']?.validate();
          return;
        }
      }

      if (_formKey.currentState?.saveAndValidate() ?? false) {
        var request = Map.from(_formKey.currentState!.value);
        request['ulogaId'] = 2;
        request['voziloId'] = 1;

        if (_imageFile != null) {
          final imageBytes = await _imageFile!.readAsBytes();
          request['slikaProfila'] = base64Encode(imageBytes);
        } else {
          const assetImagePath = 'assets/images/autoservis_prazna_slika.jpg';
          var imageFile = await rootBundle.load(assetImagePath);
          final imageBytes = imageFile.buffer.asUint8List();
          request['slikaProfila'] = base64Encode(imageBytes);
        }

        try {
          if (widget.autoservis == null) {
            await _autoservisProvider.insert(request);
          } else {
            await _autoservisProvider.update(
                widget.autoservis!.autoservisId!,
                request);
          }
          Navigator.pop(context);
        } on Exception {
          showDialog(
            context: context,
            builder: (BuildContext context) => const AlertDialog(
              title: Text("Greška"),
              content: Text("Lozinke se ne podudaraju. Molimo unesite ispravne podatke"),
              actions: [],
            ),
          );
        }
      }
    },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 253, 23, 7),
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

  Future<void> _editUsluga(Usluge usluga) async {
    // Example implementation - you might want to navigate to an edit screen
    final editedUsluga = await showDialog<Usluge>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uredi uslugu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: usluga.nazivUsluge),
              decoration: const InputDecoration(labelText: 'Naziv usluge'),
              onChanged: (value) => usluga.nazivUsluge = value,
            ),
            TextField(
              controller:
                  TextEditingController(text: usluga.cijena?.toString()),
              decoration: const InputDecoration(labelText: 'Cijena'),
              keyboardType: TextInputType.number,
              onChanged: (value) => usluga.cijena = double.tryParse(value),
            ),
            TextField(
              controller: TextEditingController(text: usluga.opis),
              decoration: const InputDecoration(labelText: 'Opis'),
              onChanged: (value) => usluga.opis = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, usluga);
            },
            child: const Text('Spremi'),
          ),
        ],
      ),
    );

    if (editedUsluga != null) {
      try {
        // ignore: use_build_context_synchronously
        final provider = Provider.of<UslugeProvider>(context, listen: false);
        await provider.update(editedUsluga.uslugeId, editedUsluga);
        setState(() {
          // Update the local list
          final index =
              usluge.indexWhere((u) => u.uslugeId == editedUsluga.uslugeId);
          if (index != -1) {
            usluge[index] = editedUsluga;
          }
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usluga uspješno ažurirana')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri ažuriranju: $e')),
        );
      }
    }
  }

  Future<void> _deleteUsluga(Usluge usluga) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
            'Da li ste sigurni da želite obrisati uslugu ${usluga.nazivUsluge}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<UslugeProvider>(context, listen: false);
        await provider.delete(usluga.uslugeId);
        setState(() {
          usluge.removeWhere((u) => u.uslugeId == usluga.uslugeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usluga ${usluga.nazivUsluge} obrisana')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri brisanju: $e')),
        );
      }
    }
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
                          final klijentId = userProvider
                              .userId; // Dohvati ID logiranog klijenta
                          final autoservisId = widget.autoservis!.autoservisId!;

                          // Prikaži popup za unos poruke
                          _showSendMessageDialog(
                              context, klijentId, autoservisId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 248, 26, 10),
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
                )),
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
                      // ignore: deprecated_member_use
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
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.black),
                          SizedBox(height: 10),
                          Text('Odaberite sliku',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
                        ],
                      ),
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
    final isAdmin = context.read<UserProvider>().role == "Admin" ||
        (context.read<UserProvider>().role == "Autoservis" &&
            context.read<UserProvider>().userId ==
                widget.autoservis
                    ?.autoservisId); // Proveravamo da li je korisnik Admin

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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "naziv",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue: widget.autoservis?.naziv ?? "",
              validator: validator.required, // Održavanje unetog teksta
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "vlasnikFirme",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue: widget.autoservis?.vlasnikFirme ?? "",
              validator: validator.required,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Ostala polja
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "adresa",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue:
                  widget.autoservis?.adresa ?? "", // Održavanje unetog teksta
              validator: validator.required,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: FormBuilderDropdown(
              name: 'gradId',
              validator: validator.required,
              decoration: const InputDecoration(
                labelText: 'Grad',
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Izaberite grad',
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              initialValue: widget.autoservis?.gradId?.toString(),
              items: gradResult?.result
                      .map((item) => DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: item.gradId.toString(),
                            child: Text(
                              item.nazivGrada ?? "",
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ))
                      .toList() ??
                  [],
              enabled: context.read<UserProvider>().role == "Admin" ||
                  (context.read<UserProvider>().role == "Autoservis" &&
                      context.read<UserProvider>().userId ==
                          widget.autoservis!.autoservisId), // Enable if Admin
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Polja za telefon, email, JIB i MBS
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "telefon",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue: widget.autoservis?.telefon ?? "",
              validator: validator.phoneNumber, // Održavanje unetog teksta
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "email",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue:
                  widget.autoservis?.email ?? "", // Održavanje unetog teksta
              validator: validator.email,
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "jib",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue:
                  widget.autoservis?.jib ?? "", // Održavanje unetog teksta
              validator: validator.jib,
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Crni okvir
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Crni okvir kada je disabled
                ),
                labelStyle:
                    TextStyle(color: Colors.black), // Crni tekst za labelu
                hintStyle: TextStyle(color: Colors.black), // Crni tekst za hint
              ),
              name: "mbs",
              enabled: isAdmin, // Ako nije admin, polje je disabled
              style: const TextStyle(
                  color: Colors.black), // Crni tekst unutar inputa
              initialValue:
                  widget.autoservis?.mbs ?? "", // Održavanje unetog teksta
              validator: validator.mbs,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Korisničko ime, lozinka i ponovljena lozinka (samo za admina)
      isAdmin
          ? Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: "username",
                    decoration: const InputDecoration(
                      labelText: "Korisničko ime",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white, // Bela pozadina
                      filled: true, // Da pozadina bude ispunjena
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black), // Crni okvir
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Crni okvir kada je disabled
                      ),
                      labelStyle: TextStyle(
                          color: Colors.black), // Crni tekst za labelu
                      hintStyle:
                          TextStyle(color: Colors.black), // Crni tekst za hint
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite korisničko ime';
                      }
                      if (_usernameExists) {
                        return 'Korisničko ime već postoji';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _usernameExists = false;
                        });
                      }
                    },
                    style: const TextStyle(
                        color: Colors.black), // Crni tekst unutar inputa
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(), // Sakrivanje za ne-admin korisnike

      const SizedBox(height: 20),

      isAdmin
          ? Row(
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
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black), // Crni okvir
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Crni okvir kada je disabled
                      ),
                      labelStyle: TextStyle(
                          color: Colors.black), // Crni tekst za labelu
                      hintStyle:
                          TextStyle(color: Colors.black), // Crni tekst za hint
                    ),
                    name: "password",
                    initialValue: widget.autoservis?.password ??
                        "", // Održavanje unetog teksta
                    validator: validator.required,
                    obscureText: true, // Da lozinka bude sakrivena
                    style: const TextStyle(
                        color: Colors.black), // Crni tekst unutar inputa
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(), // Sakrivanje za ne-admin korisnike

      const SizedBox(height: 20),

      isAdmin
          ? Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    decoration: const InputDecoration(
                      labelText: "Ponovite lozinku",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white, // Bela pozadina
                      filled: true, // Da pozadina bude ispunjena
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black), // Crni okvir
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black), // Crni okvir kada je disabled
                      ),
                      labelStyle: TextStyle(
                          color: Colors.black), // Crni tekst za labelu
                      hintStyle:
                          TextStyle(color: Colors.black), // Crni tekst za hint
                    ),
                    name: "passwordAgain",
                    initialValue: "", // Održavanje unetog teksta
                    validator: validator.lozinkaAgain,
                    obscureText: true, // Da lozinka bude sakrivena
                    style: const TextStyle(
                        color: Colors.black), // Crni tekst unutar inputa
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(), // Sakrivanje za ne-admin korisnike
    ];
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
                  validator: validator.required,
                ),
                FormBuilderTextField(
                  name: "cijena",
                  decoration: const InputDecoration(labelText: "Cijena"),
                  keyboardType: TextInputType.number,
                  validator: validator.required,
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
                // Provjera validacije forme
                if (!(uslugaFormKey.currentState?.validate() ?? false)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Molimo popunite obavezna polja."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return; // Zaustavi obradu ako validacija nije prošla
                }

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
                    validator: validator.required,
                  ),
                  FormBuilderTextField(
                    name: "prezime",
                    decoration: const InputDecoration(labelText: "Prezime"),
                    validator: validator.required,
                  ),
                  FormBuilderTextField(
                    name: 'adresa',
                    decoration: const InputDecoration(
                      labelText: 'Adresa',
                    ),
                    validator: validator.required,
                  ),
                  FormBuilderDropdown<String>(
                    name: 'gradId',
                    decoration: const InputDecoration(
                      labelText: 'Izaberite grad',
                    ),
                    validator: validator.required,
                    items: gradResult?.result.map((item) {
                          return DropdownMenuItem(
                            value: item.gradId.toString(),
                            child: Text(
                              item.nazivGrada ?? "",
                              style: TextStyle(
                                color: item.vidljivo == false
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                  FormBuilderTextField(
                      name: "mb",
                      decoration:
                          const InputDecoration(labelText: "Matični broj"),
                      keyboardType: TextInputType.number,
                      validator: validator.numberWith12DigitsOnly),
                  FormBuilderTextField(
                    name: "brojTelefona",
                    decoration:
                        const InputDecoration(labelText: "Broj telefona"),
                    keyboardType: TextInputType.phone,
                    validator: validator.phoneNumber,
                  ),
                  FormBuilderDateTimePicker(
                    name: "datumRodjenja",
                    inputType: InputType.date,
                    decoration:
                        const InputDecoration(labelText: "Datum Rođenja"),
                    format: DateFormat("dd.MM.yyyy"),
                  ),
                  FormBuilderTextField(
                    name: "email",
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: validator.email,
                  ),
                  FormBuilderTextField(
                    name: "username",
                    decoration: const InputDecoration(
                      labelText: "Korisničko ime",
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite korisničko ime';
                      }
                      if (_usernameExists) {
                        return 'Korisničko ime već postoji';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _usernameExists = false;
                        });
                      }
                    },
                  ),
                  FormBuilderTextField(
                    name: "password",
                    decoration: const InputDecoration(labelText: "Lozinka"),
                    obscureText: true,
                    validator: validator.required,
                  ),
                  FormBuilderTextField(
                    name: "passwordAgain",
                    decoration:
                        const InputDecoration(labelText: "Ponovi lozinku"),
                    obscureText: true,
                    validator: validator.required,
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
                if (!(zaposlenikFormKey.currentState?.validate() ?? false)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Molimo popunite obavezna polja."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Provjera username-a
                final username =
                    zaposlenikFormKey.currentState?.fields['username']?.value;
                if (username != null && username.toString().isNotEmpty) {
                  final exists =
                      await _zaposlenikProvider.checkUsernameExists(username);
                  if (exists) {
                    setState(() {
                      _usernameExists = true;
                    });
                    zaposlenikFormKey.currentState?.fields['username']
                        ?.validate();
                    return;
                  }
                }

                zaposlenikFormKey.currentState?.saveAndValidate();
                var zaposlenikRequest = Map<String, dynamic>.from(
                    zaposlenikFormKey.currentState!.value);

                // Provjeri da li `mb` postoji i nije null
                if (zaposlenikRequest['mb'] == null ||
                    zaposlenikRequest['mb'].toString().trim().isEmpty) {
                  zaposlenikRequest['mb'] =
                      ""; // Postavi praznu vrijednost ako je null
                }

                // Konverzija datuma u ISO format
                if (zaposlenikRequest['datumRodjenja'] != null) {
                  zaposlenikRequest['datumRodjenja'] =
                      (zaposlenikRequest['datumRodjenja'] as DateTime)
                          .toIso8601String();
                }

                zaposlenikRequest['ulogaId'] = 1;
                zaposlenikRequest['autoservisId'] =
                    widget.autoservis?.autoservisId;
                zaposlenikRequest['mb'] =
                    zaposlenikFormKey.currentState!.value['mb'] ??
                        "384748494949";

                print("Zaposlenik request: $zaposlenikRequest"); // Debug ispis

                try {
                  await _zaposlenikProvider.insert(zaposlenikRequest);
                  Navigator.pop(context);
                  fetchZaposlenik();
                } catch (e) {
                  showDialog(
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
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Otkaži"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Provider.of<ChatAutoservisKlijentProvider>(
                        context,
                        listen: false,
                      ).sendMessage(klijentId, autoservisId, message);

                      if (mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
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

  Future<void> _editZaposlenik(Zaposlenik zap) async {
    // Future<void> _editZaposlenik(Zaposlenik zap) async {
    final editedZap = await showDialog<Zaposlenik>(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to manage state within the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Uredi zaposlenika'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: TextEditingController(text: zap.ime),
                      decoration: const InputDecoration(labelText: 'Ime'),
                      onChanged: (value) => zap.ime = value,
                    ),
                    TextField(
                      controller: TextEditingController(text: zap.prezime),
                      decoration: const InputDecoration(labelText: 'Prezime'),
                      onChanged: (value) => zap.prezime = value,
                    ),
                    TextField(
                      controller: TextEditingController(text: zap.mb),
                      decoration:
                          const InputDecoration(labelText: 'Matični broj'),
                      onChanged: (value) => zap.mb = value,
                    ),
                    TextField(
                      controller: TextEditingController(text: zap.brojTelefona),
                      decoration:
                          const InputDecoration(labelText: 'Broj telefona'),
                      onChanged: (value) => zap.brojTelefona = value,
                    ),
                    FormBuilderDateTimePicker(
                      name: "datumRodjenja",
                      inputType: InputType.date,
                      decoration:
                          const InputDecoration(labelText: "Datum Rođenja"),
                      format: DateFormat("dd.MM.yyyy"),
                      initialValue: zap.datumRodjenja, // Use DateTime directly
                      onChanged: (DateTime? value) {
                        if (value != null) {
                          zap.datumRodjenja = value; // Store DateTime directly
                        }
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: zap.email),
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => zap.email = value,
                    ),
                    TextField(
                      controller: TextEditingController(text: zap.username),
                      decoration:
                          const InputDecoration(labelText: 'Korisničko ime'),
                      onChanged: (value) => zap.username = value,
                    ),
                    TextField(
                      controller: TextEditingController(text: zap.password),
                      decoration: const InputDecoration(labelText: 'Lozinka'),
                      onChanged: (value) => zap.password = value,
                      obscureText: true,
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: zap.passwordAgain),
                      decoration:
                          const InputDecoration(labelText: 'Lozinka ponovo'),
                      onChanged: (value) => zap.passwordAgain = value,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Otkaži'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, zap);
                  },
                  child: const Text('Spremi'),
                ),
              ],
            );
          },
        );
      },
    );

    if (editedZap != null) {
      try {
        final provider =
            Provider.of<ZaposlenikProvider>(context, listen: false);
        await provider.update(editedZap.zaposlenikId!, editedZap);
        setState(() {
          final index = zaposlenik
              .indexWhere((u) => u.zaposlenikId == editedZap.zaposlenikId);
          if (index != -1) {
            zaposlenik[index] = editedZap;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zaposlenik uspješno ažuriran')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri ažuriranju: $e')),
        );
      }
    }
  }

  Future<void> _deleteZaposlenik(Zaposlenik zap) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
            'Da li ste sigurni da želite obrisati zaposlenika ${zap.ime}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider =
            Provider.of<ZaposlenikProvider>(context, listen: false);
        await provider.delete(zap.zaposlenikId!);
        setState(() {
          zaposlenik.removeWhere((u) => u.zaposlenikId == zap.zaposlenikId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zaposlenik ${zap.ime} obrisan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri brisanju: $e')),
        );
      }
    }
  }
}
