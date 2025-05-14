// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
    if (context.read<UserProvider>().role == "Admin") {
      gradResult = await _gradProvider.getAdmin();
      ulogaResult = await _ulogaProvider.getAdmin();
    } else {
      gradResult = await _gradProvider.get();
      ulogaResult = await _ulogaProvider.get();
    }
    temp = await _bpProvider
        .getById(widget.firmaAutodijelova?.firmaAutodijelovaID ?? 0);

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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.firmaAutodijelova?.nazivFirme ?? "Detalji firme"),
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
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (context.read<UserProvider>().role == "Admin" ||
                              ((context.read<UserProvider>().role ==
                                      "Firma autodijelova") &&
                                  context.read<UserProvider>().userId ==
                                      widget.firmaAutodijelova!
                                          .firmaAutodijelovaID))
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  final userProvider =
                                      context.read<UserProvider>();
                                  final isOwnAccount = userProvider.role ==
                                          "Firma autodijelova" &&
                                      userProvider.userId ==
                                          widget.firmaAutodijelova
                                              ?.firmaAutodijelovaID;
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Potvrda brisanja"),
                                      content: const Text(
                                          "Da li ste sigurni da želite izbrisati ovu firmu utodijelova?"),
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

                                  if (confirmDelete == true) {
                                    try {
                                      await _firmaAutodijelovaProvider.delete(
                                          widget.firmaAutodijelova!
                                              .firmaAutodijelovaID);

                                      if (isOwnAccount) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LogInPage(),
                                          ),
                                        );
                                      } else {
                                        Navigator.pop(context);
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Firma autodijelova uspješno izbrisana."),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                  backgroundColor:
                                      const Color.fromARGB(255, 249, 12, 12),
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
                          ElevatedButton(
                            onPressed: () async {
                              if (!(_formKey.currentState?.validate() ??
                                  false)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Molimo popunite obavezna polja."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                var request =
                                    Map.from(_formKey.currentState!.value);
                                request['ulogaId'] = 3;

                                if (_imageFile != null) {
                                  final imageBytes =
                                      await _imageFile!.readAsBytes();
                                  request['slikaProfila'] =
                                      base64Encode(imageBytes);
                                } else {
                                  const assetImagePath =
                                      'assets/images/firma_prazna_slika.jpg';
                                  var imageFile =
                                      await rootBundle.load(assetImagePath);
                                  final imageBytes =
                                      imageFile.buffer.asUint8List();
                                  request['slikaProfila'] =
                                      base64Encode(imageBytes);
                                }

                                try {
                                  final username = _formKey
                                      .currentState?.fields['username']?.value;
                                  if (username != null &&
                                      username.toString().isNotEmpty) {
                                    final exists =
                                        await _firmaAutodijelovaProvider
                                            .checkUsernameExists(username);
                                    if (exists &&
                                        (widget.firmaAutodijelova == null ||
                                            widget.firmaAutodijelova?.username
                                                    ?.toLowerCase() !=
                                                username.toLowerCase())) {
                                      setState(() {
                                        _usernameExists = true;
                                      });
                                      _formKey.currentState?.fields['username']
                                          ?.validate();
                                      return;
                                    }
                                  }

                                  if (widget.firmaAutodijelova == null) {
                                    await _firmaAutodijelovaProvider
                                        .insert(request);
                                  } else {
                                    await _firmaAutodijelovaProvider.update(
                                        widget.firmaAutodijelova!
                                            .firmaAutodijelovaID,
                                        request);
                                  }
                                  Navigator.pop(context);
                                } on Exception {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        const AlertDialog(
                                      title: Text("Greška"),
                                      content: Text(
                                          "Lozinke se ne podudaraju. Molimo unesite ispravne podatke"),
                                      actions: [],
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 253, 23, 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Spasi"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BPAutodijeloviAutoservisScreen(
                                    firmaAutodijelova: widget.firmaAutodijelova,
                                  ),
                                ),
                              );
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
                                Icon(Icons.storage),
                                SizedBox(width: 8.0),
                                Text('Baza autoservisa'),
                              ],
                            ),
                          ),
                        ],
                      ),
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
    return [
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              decoration: const InputDecoration(
                labelText: "Naziv firme",
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite naziv firme',
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
              name: "nazivFirme",
              validator: validator.nazivFirme,
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
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
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite adresu',
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
              name: "adresa",
              validator: validator.adresa,
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
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
              initialValue: widget.firmaAutodijelova?.gradId?.toString(),
              items: gradResult?.result
                      .map((item) => DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: item.gradId.toString(),
                            child: Text(
                              item.nazivGrada ?? "",
                              style: TextStyle(
                                color: item.vidljivo == false
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ))
                      .toList() ??
                  [],
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
            ),
          )
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              decoration: const InputDecoration(
                labelText: "Telefon",
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite telefon',
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
              name: "telefon",
              validator: validator.phoneNumber,
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite email',
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
              name: "email",
              validator: validator.email,
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
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
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite JIB',
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
              name: "jib",
              validator: validator.jib,
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              decoration: const InputDecoration(
                labelText: "MBS",
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite MBS',
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
              name: "mbs",
              validator: validator.mbs,
              enabled: context.read<UserProvider>().role == "Admin" ||
                  ((context.read<UserProvider>().role ==
                          "Firma autodijelova") &&
                      context.read<UserProvider>().userId ==
                          widget.firmaAutodijelova!.firmaAutodijelovaID),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      if (context.read<UserProvider>().role == "Admin" ||
          ((context.read<UserProvider>().role == "Firma autodijelova") &&
              context.read<UserProvider>().userId ==
                  widget.firmaAutodijelova!.firmaAutodijelovaID)) ...[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Korisničko ime",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            FormBuilderTextField(
              name: "username",
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite korisničko ime',
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
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
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
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lozinka",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            FormBuilderTextField(
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Unesite lozinku',
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
              name: "password",
              validator: validator.required,
              obscureText: true,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ponovite lozinku",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            FormBuilderTextField(
              decoration: const InputDecoration(
                labelText: "Ponovite lozinku",
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'Ponovo unesite lozinku',
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
              name: "passwordAgain",
              validator: validator.lozinkaAgain,
              obscureText: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ];
  }
}
