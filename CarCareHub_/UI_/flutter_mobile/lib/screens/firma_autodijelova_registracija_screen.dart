import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FirmaAutodijelovaRegistracijaScreen extends StatefulWidget {
  FirmaAutodijelova? firmaAutodijelova;
  FirmaAutodijelovaRegistracijaScreen({super.key, this.firmaAutodijelova});

  @override
  State<FirmaAutodijelovaRegistracijaScreen> createState() =>
      _FirmaAutodijelovaRegistracijaScreenState();
}

class _FirmaAutodijelovaRegistracijaScreenState
    extends State<FirmaAutodijelovaRegistracijaScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  late UslugeProvider _uslugaProvider;
  late GradProvider _gradProvider;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  SearchResult<Grad>? gradResult;
  List<Usluge> usluge = [];
  bool isLoading = true;

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
    _uslugaProvider = context.read<UslugeProvider>();
    _gradProvider = context.read<GradProvider>();

    initForm();
    fetchUsluge();
  }

  Future initForm() async {
    gradResult = await _gradProvider.get();
    if (widget.firmaAutodijelova != null && widget.firmaAutodijelova!.slikaProfila != null) {
      _imageFile =
          await _getImageFileFromBase64(widget.firmaAutodijelova!.slikaProfila!);
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
    usluge =
        await _uslugaProvider.getById(widget.firmaAutodijelova?.firmaAutodijelovaID ?? 0);
    setState(() {});
  }

  Future<void> _saveForm() async {
    _formKey.currentState?.saveAndValidate();
    var request = Map.from(_formKey.currentState!.value);

    // Dodavanje slike (ako postoji)
    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      request['slikaProfila'] = base64Image; // Dodaj sliku u request
    }

    try {
      if (widget.firmaAutodijelova == null) {
        await _firmaAutodijelovaProvider.insert(request);
      } else {
        await _firmaAutodijelovaProvider.update(
          widget.firmaAutodijelova!.firmaAutodijelovaID!,
          request,
        );
      }
    } on Exception catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Error"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.firmaAutodijelova?.nazivFirme ?? "Registracija firme autodijelova"),
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
                          ElevatedButton(
                            onPressed: _saveForm,
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
                          )
                        ],
                      ),
                    )
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
          const SizedBox(height: 8),
          ..._buildFormFields(),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
  return [
    // Red 1: Naziv i adresa
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Naziv firme autodijelova:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "nazivFirme",
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Adresa:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "adresa",
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 2: grad
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Korisničko ime",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        FormBuilderTextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          name: "username",
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 3: Lozinka
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lozinka",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        FormBuilderTextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          name: "password",
          obscureText: true,
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 4: Ponovljena Lozinka
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ponovite lozinku",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        FormBuilderTextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          name: "passwordAgain",
          obscureText: true,
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 5: Adresa i Grad
    Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Grad",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderDropdown(
                name: 'gradId',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  hintText: 'Izaberite grad',
                ),
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
      ],
    ),
    const SizedBox(height: 20),

    // Red 6: Email i Broj telefona
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "email",
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Broj telefona",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "telefon",
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 7: JIB i MBS
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "JIB",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "jib",
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MBS",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "mbs",
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),
  ];
}

    }