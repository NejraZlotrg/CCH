import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/main.dart';
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
  try {
    print('Fetching grad with ID: ${widget.autoservis?.gradId}');
    grad = await _gradProvider.getById(widget.autoservis?.gradId);

    if (grad.isNotEmpty && grad.first.vidljivo == false) {
      grad = []; // Postavi na praznu listu ako grad nije vidljiv
      _initialValues['gradId']; // Resetuj vrednost za dropdown

      if (mounted) {
        setState(() {});
      }
    }
  } catch (e) {
    print('Error fetching grad: $e');
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 204, 204, 204),
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

Container(
  padding: const EdgeInsets.only(left: 15),
  child: const Align(
    alignment: Alignment.centerLeft,
    child: Text(
      "Usluge",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  ),
)
,

                  // Usluge
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: usluge.isNotEmpty
                        ? Column(
                            children: usluge.map((usluga) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(usluga.nazivUsluge ?? "",
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text("Cijena: ${usluga.cijena?.toString() ?? ''} KM"),
                                      const SizedBox(height: 4),
                                      Text("Opis: ${usluga.opis ?? ''}"),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _editUsluga(usluga),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteUsluga(usluga),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const Text("Nema dostupnih usluga za ovaj autoservis."),
                  ),

                  if (context.read<UserProvider>().role == "Admin" ||
                      (context.read<UserProvider>().role == "Autoservis" &&
                          context.read<UserProvider>().userId ==
                              widget.autoservis?.autoservisId))
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () => _showAddUslugaDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 251, 26, 10),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text("Dodaj uslugu"),
                      ),
                    ),


Container(
  padding: const EdgeInsets.only(left: 15),
  child: const Align(
    alignment: Alignment.centerLeft,
    child: Text(
      "Zaposlenici",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  ),
)
,
                  // Zaposlenici
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: zaposlenik.isNotEmpty
                        ? Column(
                            children: zaposlenik.map((zap) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${zap.ime ?? ''} ${zap.prezime ?? ''}",
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text("Email: ${zap.email ?? ''}"),
                                      const SizedBox(height: 4),
                                      Text("Telefon: ${zap.brojTelefona ?? ''}"),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _editZaposlenik(zap),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteZaposlenik(zap),
                                          ),
                                          if (context.read<UserProvider>().role == "Klijent")
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                final klijentId = context.read<UserProvider>().userId;
                                                final zaposleniId = zap.zaposlenikId!;
                                                _showSendMessageDialog2(
                                                    context, klijentId, zaposleniId);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 247, 28, 13),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              icon: const Icon(Icons.chat),
                                              label: const Text("Pošaljite poruku"),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const Text("Nema dostupnih zaposlenika za ovaj autoservis."),
                  ),

                  if (context.read<UserProvider>().role == "Admin" ||
                      (context.read<UserProvider>().role == "Autoservis" &&
                          context.read<UserProvider>().userId ==
                              widget.autoservis?.autoservisId))
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () => _showAddZaposlenikDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 253, 27, 11),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text("Dodaj zaposlenika"),
                      ),
                    ),

                  // Dugmad za brisanje i spremanje
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (context.read<UserProvider>().role == "Admin" ||
                          (context.read<UserProvider>().role == "Autoservis" &&
                              context.read<UserProvider>().userId ==
                                  widget.autoservis?.autoservisId))
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            onPressed: () async {
                              final userProvider = context.read<UserProvider>();
                              final isOwnAccount = userProvider.role == "Autoservis" &&
                                  userProvider.userId == widget.autoservis?.autoservisId;

                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Potvrda brisanja"),
                                  content: const Text(
                                      "Da li ste sigurni da želite izbrisati ovaj autoservis?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Otkaži"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Izbriši"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                try {
                                  await _autoservisProvider
                                      .delete(widget.autoservis!.autoservisId!);

                                  if (isOwnAccount) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const LogInPage(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Autoservis uspješno izbrisan."),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Greška prilikom brisanja: ${e.toString()}"),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromARGB(255, 249, 11, 11),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Molimo popunite obavezna polja."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            final username = _formKey.currentState?.fields['username']?.value;
                            if (username != null && username.toString().isNotEmpty) {
                              final exists = await _autoservisProvider.checkUsernameExists(username);
                              if (exists &&
                                  (widget.autoservis == null ||
                                      widget.autoservis?.username?.toLowerCase() !=
                                          username.toLowerCase())) {
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
                                      widget.autoservis!.autoservisId!, request);
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
                            backgroundColor: const Color.fromARGB(255, 253, 23, 7),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  final nazivController = TextEditingController(text: usluga.nazivUsluge);
  final cijenaController =
      TextEditingController(text: usluga.cijena?.toString());
  final opisController = TextEditingController(text: usluga.opis);

  final editedUsluga = await showDialog<Usluge>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Uredi uslugu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nazivController,
              decoration: const InputDecoration(labelText: 'Naziv usluge'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cijenaController,
              decoration: const InputDecoration(labelText: 'Cijena'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: opisController,
              decoration: const InputDecoration(labelText: 'Opis'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
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
            usluga.nazivUsluge = nazivController.text;
            usluga.cijena = double.tryParse(cijenaController.text);
            usluga.opis = opisController.text;
            Navigator.pop(context, usluga);
          },
          child: const Text('Spremi'),
        ),
      ],
    ),
  );

  if (editedUsluga != null) {
    try {
      final provider = Provider.of<UslugeProvider>(context, listen: false);
      await provider.update(editedUsluga.uslugeId, editedUsluga);
      setState(() {
        final index =
            usluge.indexWhere((u) => u.uslugeId == editedUsluga.uslugeId);
        if (index != -1) {
          usluge[index] = editedUsluga;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usluga uspješno ažurirana')),
      );
    } catch (e) {
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
      content: SingleChildScrollView(
        child: Text(
          'Da li ste sigurni da želite obrisati uslugu "${usluga.nazivUsluge}"?',
        ),
      ),
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
        SnackBar(content: Text('Usluga "${usluga.nazivUsluge}" obrisana')),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.role == "Klijent") {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final klijentId = userProvider.userId;
                      final autoservisId = widget.autoservis!.autoservisId!;
                      _showSendMessageDialog(context, klijentId, autoservisId);
                    },
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text("Pošalji poruku"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 248, 26, 10),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            size: 50, color: Colors.black54),
                        SizedBox(height: 8),
                        Text('Odaberite sliku',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15)),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _buildFormFields(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}


List<Widget> _buildFormFields() {
  final isAdmin = context.read<UserProvider>().role == "Admin" ||
      (context.read<UserProvider>().role == "Autoservis" &&
          context.read<UserProvider>().userId == widget.autoservis?.autoservisId);

  return [
    FormBuilderTextField(
      decoration: _inputDecoration("Naziv autoservisa"),
      name: "naziv",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.naziv ?? "",
      validator: validator.required,
    ),
    const SizedBox(height: 15),

    FormBuilderTextField(
      decoration: _inputDecoration("Vlasnik autoservisa"),
      name: "vlasnikFirme",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.vlasnikFirme ?? "",
      validator: validator.required,
    ),
    const SizedBox(height: 15),

    FormBuilderTextField(
      decoration: _inputDecoration("Adresa"),
      name: "adresa",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.adresa ?? "",
      validator: validator.required,
    ),
    const SizedBox(height: 15),

    FormBuilderDropdown(
      name: 'gradId',
      validator: validator.required,
      decoration: _inputDecoration("Grad", hint: "Izaberite grad"),
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.gradId?.toString(),
      items: gradResult?.result.map((item) => DropdownMenuItem(
        alignment: AlignmentDirectional.center,
        value: item.gradId.toString(),
        child: Text(item.nazivGrada ?? "", style: const TextStyle(color: Colors.black)),
      )).toList() ?? [],
      enabled: isAdmin,
    ),
    const SizedBox(height: 15),

    FormBuilderTextField(
      decoration: _inputDecoration("Telefon"),
      name: "telefon",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.telefon ?? "",
      validator: validator.phoneNumber,
    ),
    const SizedBox(height: 15),

    FormBuilderTextField(
      decoration: _inputDecoration("Email"),
      name: "email",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.email ?? "",
      validator: validator.email,
    ),
    const SizedBox(height: 15),

    FormBuilderTextField(
      decoration: _inputDecoration("JIB"),
      name: "jib",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.jib ?? "",
      validator: validator.jib,
    ),
    const SizedBox(height: 15),

    FormBuilderTextField(
      decoration: _inputDecoration("MBS"),
      name: "mbs",
      enabled: isAdmin,
      style: const TextStyle(color: Colors.black),
      initialValue: widget.autoservis?.mbs ?? "",
      validator: validator.mbs,
    ),
    const SizedBox(height: 15),

    if (isAdmin) ...[
      FormBuilderTextField(
        name: "username",
        decoration: _inputDecoration("Korisničko ime"),
        validator: (value) {
          if (value == null || value.isEmpty || value.length < 3 || value.length > 50) {
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
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 15),

      FormBuilderTextField(
        decoration: _inputDecoration("Lozinka", hint: "Unesite lozinku"),
        name: "password",
        validator: validator.password,
        obscureText: true,
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 15),

      FormBuilderTextField(
        decoration: _inputDecoration("Ponovite lozinku"),
        name: "passwordAgain",
        initialValue: "",
        validator: validator.lozinkaAgain,
        obscureText: true,
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 15),
    ]
  ];
}

InputDecoration _inputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    labelStyle: const TextStyle(color: Colors.black),
    hintStyle: const TextStyle(color: Colors.black),
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
            contentPadding: const EdgeInsets.all(16), // Dodaj padding za komfor
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Okrugli uglovi
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Prilagodi širinu dijaloga
              child: Column(
                mainAxisSize: MainAxisSize.min, // Sažmi veličinu
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        message = value; // Ažuriraj poruku kad se unese tekst
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Unesite poruku",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding u text polju
                    ),
                    maxLines: 3, // Ograniči visinu na nekoliko linija
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
            actions: [
              // Otkaži dugme
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // Zatvori dijalog
                  }
                },
                child: const Text(
                  "Otkaži",
                  style: TextStyle(fontSize: 16), // Povećaj font za lakše čitanje
                ),
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
                          content: Text("Poruka poslana uspješno"),
                        ),
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
                        content: Text("Poruka ne može biti prazna"),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Pošaljite",
                  style: TextStyle(fontSize: 16), // Povećaj font za lakšu interakciju
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 50), // Povećaj širinu dugmeta
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
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
        contentPadding: const EdgeInsets.all(16), // Dodaj padding za komfor
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Okrugli uglovi
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // Prilagodi širinu dijaloga
          child: SingleChildScrollView( // Dodaj SingleChildScrollView za scrollable sadržaj
            child: FormBuilder(
              key: uslugaFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: "nazivUsluge",
                    decoration: const InputDecoration(
                      labelText: "Naziv usluge",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Unutrašnji padding
                    ),
                    validator: validator.required,
                  ),
                  const SizedBox(height: 8), // Razmak između polja
                  FormBuilderTextField(
                    name: "cijena",
                    decoration: const InputDecoration(
                      labelText: "Cijena",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Unutrašnji padding
                    ),
                    keyboardType: TextInputType.number,
                    validator: validator.required,
                  ),
                  const SizedBox(height: 8), // Razmak između polja
                  FormBuilderTextField(
                    name: "opis",
                    decoration: const InputDecoration(
                      labelText: "Opis",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Unutrašnji padding
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Odustani",
              style: TextStyle(fontSize: 16), // Povećaj font za bolju interakciju
            ),
          ),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 50), // Povećaj širinu dugmeta
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            child: const Text(
              "Dodaj",
              style: TextStyle(fontSize: 16), // Povećaj font za bolju interakciju
            ),
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
        contentPadding: const EdgeInsets.all(16), // Dodaj padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Okrugli uglovi
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% širine ekrana
          child: SingleChildScrollView(
            child: FormBuilder(
              key: zaposlenikFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: "ime",
                    decoration: const InputDecoration(
                      labelText: "Ime",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    validator: validator.prezime,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "prezime",
                    decoration: const InputDecoration(
                      labelText: "Prezime",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    validator: validator.prezime,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'adresa',
                    decoration: const InputDecoration(
                      labelText: 'Adresa',
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    validator: validator.adresa,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderDropdown<String>(
                    name: 'gradId',
                    decoration: const InputDecoration(
                      labelText: 'Izaberite grad',
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    validator: validator.required,
                    items: gradResult?.result.map((item) {
                      return DropdownMenuItem(
                        value: item.gradId.toString(),
                        child: Text(
                          item.nazivGrada ?? "",
                          style: TextStyle(
                            color: item.vidljivo == false ? Colors.red : Colors.black,
                          ),
                        ),
                      );
                    }).toList() ?? [],
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "mb",
                    decoration: const InputDecoration(
                      labelText: "Matični broj",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    keyboardType: TextInputType.number,
                    validator: validator.numberWith12DigitsOnly,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "brojTelefona",
                    decoration: const InputDecoration(
                      labelText: "Broj telefona",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: validator.phoneNumber,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderDateTimePicker(
                    name: "datumRodjenja",
                    inputType: InputType.date,
                    decoration: const InputDecoration(
                      labelText: "Datum Rođenja",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    format: DateFormat("dd.MM.yyyy"),
                    validator: validator.required,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "email",
                    decoration: const InputDecoration(
                      labelText: "Email",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: validator.email,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "username",
                    decoration: const InputDecoration(
                      labelText: "Korisničko ime",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      final error = validator.username3char(value);
                      if (error != null) return error;

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
                        _formKey.currentState?.fields['username']?.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "password",
                    decoration: const InputDecoration(
                      labelText: "Lozinka",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    obscureText: true,
                    validator: validator.password,
                  ),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "passwordAgain",
                    decoration: const InputDecoration(
                      labelText: "Ponovi lozinku",
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    obscureText: true,
                    validator: (value) {
                      final password = zaposlenikFormKey.currentState?.fields['password']?.value;
                      if (value == null || value.isEmpty) {
                        return 'Potvrda lozinke je obavezna';
                      }
                      if (value != password) {
                        return 'Lozinke se ne podudaraju.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Odustani",
              style: TextStyle(fontSize: 16), // Povećaj font za mobilnu verziju
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final isValid = zaposlenikFormKey.currentState?.validate() ?? false;

              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Molimo popunite obavezna polja."),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              final password = zaposlenikFormKey.currentState?.fields['password']?.value;
              final passwordAgain = zaposlenikFormKey.currentState?.fields['passwordAgain']?.value;

              if (password != passwordAgain) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Greška"),
                    content: const Text("Lozinke se ne podudaraju."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("U redu"),
                      ),
                    ],
                  ),
                );
                return;
              }

              zaposlenikFormKey.currentState?.saveAndValidate();
              var zaposlenikRequest = Map<String, dynamic>.from(zaposlenikFormKey.currentState!.value);

              if (zaposlenikRequest['mb'] == null || zaposlenikRequest['mb'].toString().trim().isEmpty) {
                zaposlenikRequest['mb'] = "";
              }

              if (zaposlenikRequest['datumRodjenja'] != null) {
                zaposlenikRequest['datumRodjenja'] = (zaposlenikRequest['datumRodjenja'] as DateTime).toIso8601String();
              }

              zaposlenikRequest['ulogaId'] = 1;
              zaposlenikRequest['autoservisId'] = widget.autoservis?.autoservisId;
              zaposlenikRequest['mb'] = zaposlenikFormKey.currentState!.value['mb'] ?? "384748494949";

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
            child: const Text(
              "Dodaj",
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 50),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
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
            title: const Text("Pošaljite poruku"),
            contentPadding: const EdgeInsets.all(16), // Dodaj padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Okrugli uglovi
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% širine ekrana
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          message = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Unesite poruku",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      ),
                      maxLines: 4, // Omogućava više linija za unos
                    ),
                    const SizedBox(height: 16), // Razmak između inputa i dugmadi
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Otkaži",
                  style: TextStyle(fontSize: 16), // Veći font za mobilnu verziju
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (message.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Poruka ne može biti prazna."),
                      ),
                    );
                    return;
                  }

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
                child: const Text(
                  "Pošaljite",
                  style: TextStyle(fontSize: 16), // Veći font za mobilnu verziju
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}


Future<void> _editZaposlenik(Zaposlenik zap) async {
  final editedZap = await showDialog<Zaposlenik>(
    context: context,
    builder: (context) {
      String? passwordError;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Uredi zaposlenika'),
            contentPadding: const EdgeInsets.all(16), // Dodaj padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Okrugli uglovi
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% širine ekrana
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: TextEditingController(text: zap.ime),
                      validator: validator.prezime,
                      decoration: const InputDecoration(labelText: 'Ime'),
                      onChanged: (value) => zap.ime = value,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: zap.prezime),
                      validator: validator.prezime,
                      decoration: const InputDecoration(labelText: 'Prezime'),
                      onChanged: (value) => zap.prezime = value,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: zap.mb),
                      validator: validator.numberWith12DigitsOnly,
                      decoration: const InputDecoration(labelText: 'Matični broj'),
                      onChanged: (value) => zap.mb = value,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: zap.brojTelefona),
                      validator: validator.phoneNumber,
                      decoration: const InputDecoration(labelText: 'Broj telefona'),
                      onChanged: (value) => zap.brojTelefona = value,
                    ),
                    FormBuilderDateTimePicker(
                      name: "datumRodjenja",
                      inputType: InputType.date,
                      validator: validator.required,
                      decoration: const InputDecoration(labelText: "Datum Rođenja"),
                      format: DateFormat("dd.MM.yyyy"),
                      initialValue: zap.datumRodjenja,
                      onChanged: (DateTime? value) {
                        if (value != null) {
                          zap.datumRodjenja = value;
                        }
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: zap.email),
                      validator: validator.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => zap.email = value,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: zap.username),
                      validator: validator.username3char,
                      decoration: const InputDecoration(labelText: 'Korisničko ime'),
                      onChanged: (value) => zap.username = value,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: zap.password),
                      validator: validator.password,
                      decoration: const InputDecoration(labelText: 'Lozinka'),
                      onChanged: (value) => zap.password = value,
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: TextEditingController(),
                      validator: validator.lozinkaAgain,
                      decoration: const InputDecoration(labelText: 'Lozinka ponovo'),
                      onChanged: (value) {
                        zap.passwordAgain = value;
                        if (passwordError != null) {
                          setState(() {
                            passwordError = null;
                          });
                        }
                      },
                      obscureText: true,
                    ),
                    if (passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          passwordError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Otkaži', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (zap.password != zap.passwordAgain) {
                    setState(() {
                      passwordError = 'Lozinke se ne podudaraju.';
                    });
                  } else {
                    Navigator.pop(context, zap);
                  }
                },
                child: const Text('Spremi', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  if (editedZap != null) {
    try {
      final provider = Provider.of<ZaposlenikProvider>(context, listen: false);
      await provider.update(editedZap.zaposlenikId!, editedZap);
      setState(() {
        final index = zaposlenik.indexWhere((u) => u.zaposlenikId == editedZap.zaposlenikId);
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
    builder: (context) {
      return AlertDialog(
        title: const Text('Potvrda brisanja'),
        contentPadding: const EdgeInsets.all(16), // Dodaj padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Okrugli uglovi
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% širine ekrana
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Da li ste sigurni da želite obrisati zaposlenika ${zap.ime}?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Boja dugmeta
              minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 50),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    try {
      final provider = Provider.of<ZaposlenikProvider>(context, listen: false);
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
