import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:form_validation/form_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AutoservisRegistracijaScreen extends StatefulWidget {
  Autoservis? autoservis;
  
 // var validator = CreateValidator();
  AutoservisRegistracijaScreen({super.key, this.autoservis});

  @override
  State<AutoservisRegistracijaScreen> createState() =>
      _AutoservisRegistracijaScreenState();
}

class _AutoservisRegistracijaScreenState
    extends State<AutoservisRegistracijaScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late AutoservisProvider _autoservisProvider;
 // late UslugeProvider _uslugaProvider;
  late GradProvider _gradProvider;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  SearchResult<Grad>? gradResult;
 // List<Usluge> usluge = [];
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
      'gradId': widget.autoservis?.gradId,
      'username': widget.autoservis?.username,
      'password': widget.autoservis?.password,
      'passwordAgain': widget.autoservis?.passwordAgain,
      "slikaProfila": widget.autoservis?.slikaProfila
    };

    _autoservisProvider = context.read<AutoservisProvider>();
   // _uslugaProvider = context.read<UslugeProvider>();
    _gradProvider = context.read<GradProvider>();

    initForm();
   // fetchUsluge();
  }

  Future initForm() async {
     if (context.read<UserProvider>().role == "Admin")
        gradResult = await _gradProvider.get();
        else 
      gradResult = await _gradProvider.get();   
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

  // Future<void> fetchUsluge() async {
  //   usluge =
  //       await _uslugaProvider.getById(widget.autoservis?.autoservisId ?? 0);
  //   setState(() {});
  // }

 Future<void> _saveForm() async {
  // Save and validate form
  _formKey.currentState?.saveAndValidate();
  var request = Map.from(_formKey.currentState!.value);
  request['ulogaId'] = 2;

       if (_imageFile != null  ) {
  final imageBytes = await _imageFile!.readAsBytes();
  request['slikaProfila'] = base64Encode(imageBytes);
} else {
  // Ako nije poslana, učitaj iz assets-a
  final assetImagePath = 'assets/images/autoservis_prazna_slika.jpg';
  var imageFile = await rootBundle.load(assetImagePath);
  final imageBytes = await imageFile.buffer.asUint8List();
  request['slikaProfila'] = base64Encode(imageBytes);
}


  try {
    // If it's a new autoservis, insert it, otherwise update
    if (widget.autoservis == null) {
      await _autoservisProvider.insert(request);
    } else {
      await _autoservisProvider.update(
        widget.autoservis!.autoservisId!,
        request,
      );
    }

    // Navigate to LogInPage after successful operation
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LogInPage()),
      (Route<dynamic> route) => false,  // This will pop all the previous routes from the stack
    );
  } on Exception catch (e) {
    // Show error dialog if an exception occurs
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Error"),
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
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.autoservis?.naziv ?? "Registracija autoservisa"),
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
                            onPressed:()  {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Forma je validna, nastavite dalje
                    _saveForm();
                  } else {
                    // Forma nije validna
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Molimo popunite obavezna polja")),
                    );
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
                      ): Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 60, color: Colors.black),
              const SizedBox(height: 10),
              Text('Odaberite sliku',
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
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
    // Red 1: Naziv i Vlasnik
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Naziv autoservisa",
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
                name: "naziv",
                validator: validator.required,
                 // Dodana validacija
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
                "Vlasnik firme",
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
                name: "vlasnikFirme",
                validator: validator.required, 

              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 2: Korisničko ime
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
          validator: validator.required, 

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
          validator: validator.required,           

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
          validator: validator.required,
          obscureText: true,
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 5: Adresa i Grad
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Adresa autoservisa",
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
                validator: validator.required,
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
      "Grad",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 5),
    FormBuilderDropdown(
      name: 'gradId',
      validator: validator.required,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        hintText: 'Izaberite grad',
      ),
      items: gradResult?.result
              .map((item) => DropdownMenuItem(
                    alignment: AlignmentDirectional.center,
                    value: item.gradId.toString(),
                    child: Text(
                      item.nazivGrada ?? "",
                      style: TextStyle(
                        color: item.vidljivo == false
                            ? Colors.red // Crvena boja za "nevidljive" gradove
                            : Colors.black, // Crna boja za ostale
                      ),
                    ),
                  ))
              .toList() ??
          [],
    ),
  ],
)

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
                validator: validator.email,
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
                validator: validator.phoneNumber,
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
                validator: validator.jib,
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
                validator: validator.mbs,
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