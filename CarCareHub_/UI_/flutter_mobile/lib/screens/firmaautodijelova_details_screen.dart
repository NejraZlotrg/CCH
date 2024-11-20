import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';

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
  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogaResult;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivFirme': widget.firmaAutodijelova?.nazivFirme,
      'gradId': widget.firmaAutodijelova?.gradId,
      'ulogaId': widget.firmaAutodijelova?.ulogaId,
    };

    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogaProvider = context.read<UlogeProvider>();

    initForm();
  }

  Future<void> initForm() async {
    gradResult = await _gradProvider.get();
    ulogaResult = await _ulogaProvider.get();

    if (widget.firmaAutodijelova != null &&
        widget.firmaAutodijelova!.slikaProfila != null) {
      _imageFile = await _getImageFileFromBase64(
          widget.firmaAutodijelova!.slikaProfila!);
    }

    setState(() {
      isLoading = false;
    });
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
      backgroundColor:
          const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
      appBar: AppBar(
        title: Text(widget.firmaAutodijelova?.nazivFirme ?? "Detalji firme"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Dodali smo scroll
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
                            onPressed: () async {
                              _formKey.currentState?.saveAndValidate();

                              var request =
                                  Map.from(_formKey.currentState!.value);

                              try {
                                if (widget.firmaAutodijelova == null) {
                                  await _firmaAutodijelovaProvider
                                      .insert(request);
                                } else {
                                  await _firmaAutodijelovaProvider.update(
                                      widget.firmaAutodijelova!
                                          .firmaAutodijelovaID!,
                                      _formKey.currentState?.value);
                                }
                              } on Exception catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
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
                            },
                            child: const Text("Spasi"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red, // Beli tekst
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Zaobljeni uglovi
                              ),
                            ),
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
            // Centrirana slika u kvadratnom okviru
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
              decoration: InputDecoration(
                labelText: "Naziv firme",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "nazivFirme",
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "Adresa",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "adresa",
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
              decoration: InputDecoration(
                labelText: 'Grad',
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                hintText: 'Izaberite grad',
              ),
              initialValue: widget.firmaAutodijelova?.gradId?.toString(),
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

      // Kontakt podaci
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "Telefon",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "telefon",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "email",
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Dodatni podaci
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "JIB",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "jib",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "MBS",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "mbs",
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Password i uloga
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              name: "password",
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: FormBuilderDropdown(
              name: 'ulogaId',
              decoration: InputDecoration(
                labelText: 'Uloga',
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Bela pozadina
                filled: true, // Da pozadina bude ispunjena
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                hintText: 'Izaberite ulogu',
              ),
              initialValue: widget.firmaAutodijelova?.ulogaId?.toString(),
              items: ulogaResult?.result
                      .map((item) => DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: item.ulogaId.toString(),
                            child: Text(item.nazivUloge ?? ""),
                          ))
                      .toList() ??
                  [],
            ),
          ),
        ],
      ),
    ];
  }
}
