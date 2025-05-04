import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/screens/BPAutodijeloviAutoservis_screen.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FirmaAutodijelovaDetailScreen extends StatefulWidget {
  final FirmaAutodijelova? firmaAutodijelova;
  const FirmaAutodijelovaDetailScreen({super.key, this.firmaAutodijelova});

  @override
  State<FirmaAutodijelovaDetailScreen> createState() =>
      _FirmaAutodijelovaDetailScreenState();
}

class _FirmaAutodijelovaDetailScreenState
    extends State<FirmaAutodijelovaDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  late GradProvider _gradProvider;
  late UlogeProvider _ulogaProvider;
  late BPAutodijeloviAutoservisProvider _bpProvider;
  bool _usernameExists = false;

  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogaResult;
SearchResult<BPAutodijeloviAutoservis>? bpResult;
List<BPAutodijeloviAutoservis>? temp;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;

    final validator = CreateValidator();

  
  get firmaAutodijelova => null;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivFirme': widget.firmaAutodijelova?.nazivFirme ?? '',
      'adresa': widget.firmaAutodijelova?.adresa ?? '',
      'gradId': widget.firmaAutodijelova?.gradId ?? '',
      'jib': widget.firmaAutodijelova?.jib ?? '',
      'mbs': widget.firmaAutodijelova?.mbs ?? '',
      'telefon': widget.firmaAutodijelova?.telefon ?? '',
      'email': widget.firmaAutodijelova?.email ?? '',
      'username': widget.firmaAutodijelova?.username ?? '',
      'password': widget.firmaAutodijelova?.password ?? '',
      'passwordAgain': widget.firmaAutodijelova?.passwordAgain ?? '',
      'ulogaId': widget.firmaAutodijelova?.ulogaId ?? '',
      
    };

    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogaProvider = context.read<UlogeProvider>();
    _bpProvider = context.read<BPAutodijeloviAutoservisProvider>();



    initForm();
  }

  Future<void> initForm() async {
     if (context.read<UserProvider>().role == "Admin"){
    gradResult = await _gradProvider.getAdmin();
    ulogaResult = await _ulogaProvider.getAdmin();
     }
    else 
    {
    gradResult = await _gradProvider.get();
    ulogaResult = await _ulogaProvider.get();
     }
    temp = await _bpProvider.getById(widget.firmaAutodijelova?.firmaAutodijelovaID ?? 0);


    if (widget.firmaAutodijelova != null &&
        widget.firmaAutodijelova!.slikaProfila != null) {
      _imageFile = await _getImageFileFromBase64(
          widget.firmaAutodijelova!.slikaProfila!);
    }

      if (mounted) {
    setState(() {
      isLoading = false;
    });
  }

  }

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

  
@override
Widget build(BuildContext context) {
  final userProvider = context.read<UserProvider>();
  final bool isOwnAccount = userProvider.role == "Firma autodijelova" &&
      userProvider.userId == widget.firmaAutodijelova?.firmaAutodijelovaID;
  final bool isAdmin = userProvider.role == "Admin";
  final bool canEdit = isAdmin || isOwnAccount;

  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 204, 204, 204),
    appBar: AppBar(
      title: Text(widget.firmaAutodijelova?.nazivFirme ?? "Detalji firme"),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildForm(),
                    const SizedBox(height: 24),

                    /// Dugmad (Spasi, Izbriši, Baza autoservisa)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: [
                        // Dugme za SPAŠAVANJE
                        if (canEdit)
                          ElevatedButton(
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

                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                var request = Map.from(_formKey.currentState!.value);
                                request['ulogaId'] = 3;

                                // Slika
                                if (_imageFile != null) {
                                  final imageBytes = await _imageFile!.readAsBytes();
                                  request['slikaProfila'] = base64Encode(imageBytes);
                                } else {
                                  const assetImagePath = 'assets/images/firma_prazna_slika.jpg';
                                  var imageFile = await rootBundle.load(assetImagePath);
                                  final imageBytes = imageFile.buffer.asUint8List();
                                  request['slikaProfila'] = base64Encode(imageBytes);
                                }

                                // Username provjera
                                final username = _formKey.currentState?.fields['username']?.value;
                                if (username != null && username.toString().isNotEmpty) {
                                  final exists = await _firmaAutodijelovaProvider.checkUsernameExists(username);
                                  if (exists &&
                                      (widget.firmaAutodijelova == null ||
                                          widget.firmaAutodijelova?.username?.toLowerCase() !=
                                              username.toLowerCase())) {
                                    setState(() => _usernameExists = true);
                                    _formKey.currentState?.fields['username']?.validate();
                                    return;
                                  }
                                }

                                try {
                                  if (widget.firmaAutodijelova == null) {
                                    await _firmaAutodijelovaProvider.insert(request);
                                  } else {
                                    await _firmaAutodijelovaProvider.update(
                                        widget.firmaAutodijelova!.firmaAutodijelovaID, request);
                                  }
                                  Navigator.pop(context);
                                } on Exception {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const AlertDialog(
                                      title: Text("Greška"),
                                      content: Text("Lozinke se ne podudaraju. Molimo unesite ispravne podatke"),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Spasi"),
                          ),

                        // Dugme za BRISANJE
                        if (canEdit)
                          ElevatedButton(
                            onPressed: () async {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Potvrda brisanja"),
                                  content: const Text("Da li ste sigurni da želite izbrisati ovu firmu autodijelova?"),
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
                                  await _firmaAutodijelovaProvider
                                      .delete(widget.firmaAutodijelova!.firmaAutodijelovaID);

                                  if (isOwnAccount) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const LogInPage()),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Firma autodijelova uspješno izbrisana."),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Greška prilikom brisanja: ${e.toString()}")),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Izbriši"),
                          ),

                        // Dugme za BAZU AUTOSERVISA
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BPAutodijeloviAutoservisScreen(
                                  firmaAutodijelova: widget.firmaAutodijelova,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: const TextStyle(fontSize: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storage, size: 18),
                              SizedBox(width: 6),
                              Text('Baza autoservisa'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          Center(
            child: GestureDetector(
              
              onTap: _pickImage,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 2),
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
                      ): const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 60, color: Colors.black),
              SizedBox(height: 10),
              Text('Odaberite sliku',
                  style: TextStyle(color: Colors.black, fontSize: 16)),
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
  final bool isEditable = context.read<UserProvider>().role == "Admin" || 
    ((context.read<UserProvider>().role == "Firma autodijelova") &&
     context.read<UserProvider>().userId == widget.firmaAutodijelova?.firmaAutodijelovaID);

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.black),
      border: OutlineInputBorder(),
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  return [
    // Naziv firme
    FormBuilderTextField(
      decoration: _decoration("Naziv firme", "Unesite naziv firme"),
      style: const TextStyle(color: Colors.black),
      name: "nazivFirme",
      validator: validator.nazivFirme,
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // Adresa
    FormBuilderTextField(
      decoration: _decoration("Adresa", "Unesite adresu"),
      style: const TextStyle(color: Colors.black),
      name: "adresa",
      validator: validator.adresa,
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // Grad
    FormBuilderDropdown(
      name: 'gradId',
      validator: validator.required,
      decoration: _decoration("Grad", "Izaberite grad"),
      style: const TextStyle(color: Colors.black),
      initialValue: widget.firmaAutodijelova?.gradId?.toString(),
      items: gradResult?.result.map((item) => DropdownMenuItem(
        alignment: AlignmentDirectional.center,
        value: item.gradId.toString(),
        child: Text(
          item.nazivGrada ?? "",
          style: TextStyle(color: item.vidljivo == false ? Colors.red : Colors.black),
        ),
      )).toList() ?? [],
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // Telefon
    FormBuilderTextField(
      decoration: _decoration("Telefon", "Unesite telefon"),
      style: const TextStyle(color: Colors.black),
      name: "telefon",
      validator: validator.phoneNumber,
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // Email
    FormBuilderTextField(
      decoration: _decoration("Email", "Unesite email"),
      style: const TextStyle(color: Colors.black),
      name: "email",
      validator: validator.email,
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // JIB
    FormBuilderTextField(
      decoration: _decoration("JIB", "Unesite JIB"),
      style: const TextStyle(color: Colors.black),
      name: "jib",
      validator: validator.jib,
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // MBS
    FormBuilderTextField(
      decoration: _decoration("MBS", "Unesite MBS"),
      style: const TextStyle(color: Colors.black),
      name: "mbs",
      validator: validator.mbs,
      enabled: isEditable,
    ),
    const SizedBox(height: 20),

    // Korisnički podaci (ako je dozvoljeno)
    if (isEditable) ...[
      FormBuilderTextField(
        name: "username",
        decoration: _decoration("Korisničko ime", "Unesite korisničko ime"),
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          final error = validator.username3char(value);
          if (error != null) return error;
          if (_usernameExists) return 'Korisničko ime već postoji';
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
      const SizedBox(height: 20),

      FormBuilderTextField(
        name: "password",
        obscureText: true,
        decoration: _decoration("Lozinka", "Unesite lozinku"),
        style: const TextStyle(color: Colors.black),
        validator: validator.required,
      ),
      const SizedBox(height: 20),

      FormBuilderTextField(
        name: "passwordAgain",
        obscureText: true,
        decoration: _decoration("Ponovite lozinku", "Ponovo unesite lozinku"),
        style: const TextStyle(color: Colors.black),
        validator: validator.lozinkaAgain,
      ),
      const SizedBox(height: 20),
    ]
  ];
}

}
