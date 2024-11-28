import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/usluge.dart'; // Dodaj model za usluge
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart'; // Dodaj provider za usluge
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:image_picker/image_picker.dart';
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
    
    initForm();
    fetchUsluge(); 
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
    usluge = await _uslugaProvider.getById(widget.autoservis?.autoservisId ?? 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.autoservis?.naziv ?? "Detalji autoservisa",
      child: SingleChildScrollView(
        child: Column(
          children: [
            isLoading ? Container() : _buildForm(),
            // Prikaz usluga
            Padding(
              padding: const EdgeInsets.all(10),
              child: usluge.isNotEmpty
                  ? DataTable(
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
                    )
                  : const Text("Nema dostupnih usluga za ovaj autoservis."),
            ),
            // Dugme za dodavanje usluge
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () => _showAddUslugaDialog(),
                child: const Text("Dodaj uslugu"),
              ),
            ),
            // Prikaz slike
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                alignment: Alignment.topLeft,
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 250,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(child: Text("Odaberi sliku")),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Spremanje podataka
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState?.save();
                      var request = Map.from(_formKey.currentState!.value);
                      if (_imageFile != null) {
                        request['slikaProfila'] = base64Encode(await _imageFile!.readAsBytes());
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
                      } on Exception catch (e) {
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
                    child: const Text("Spasi"),
                  ),
                ),
              ],
            ),
          ],
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
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Naziv"),
                  name: "naziv",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Vlasnik firme"),
                  name: "vlasnikFirme",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Adresa"),
                  name: "adresa",
                ),
              ),
              Expanded(
                child: FormBuilderDropdown(
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
                      : null, // Provjera za null vrijednosti
                  items: gradResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.gradId.toString(),
                                child: Text(item.nazivGrada ?? ""),
                              ))
                          .toList() ??
                      [], // Provjera za praznu listu //////////////////////////////////////////////////////
                ),
              )
              
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Telefon"),
                  name: "telefon",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  name: "email",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "JIB"),
                  name: "jib",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "MBS"),
                  name: "mbs",
                ),
              ),
            ],
          ),
        ],
      ),
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
                  Navigator.pop(context);
                  fetchUsluge(); // Osvježi usluge nakon dodavanja nove
                } on Exception catch (e) {
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
}