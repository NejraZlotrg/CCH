import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
    gradResult = await _gradProvider.get();
    ulogaResult = await _ulogaProvider.get();
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
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
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
                        // Dugme za spašavanje
                       // Conditionally render the 'Spasi' button only for the admin
// Only render the ElevatedButton if the user is an Admin
if (context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID) 
  ElevatedButton(
    onPressed: () async {

         if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo popunite obavezna polja."),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Zaustavi obradu ako validacija nije prošla
    }
      if (_formKey.currentState?.saveAndValidate() ?? false) {
        var request = Map.from(_formKey.currentState!.value);
        request['ulogaId'] = 3;

             if (_imageFile != null  ) {
  final imageBytes = await _imageFile!.readAsBytes();
  request['slikaProfila'] = base64Encode(imageBytes);
} else {
  // Ako nije poslana, učitaj iz assets-a
  final assetImagePath = 'assets/images/firma_prazna_slika.jpg';
  var imageFile = await rootBundle.load(assetImagePath);
  final imageBytes = await imageFile.buffer.asUint8List();
  request['slikaProfila'] = base64Encode(imageBytes);
}


        try {
          if (widget.firmaAutodijelova == null) {
            await _firmaAutodijelovaProvider.insert(request);
          } else {
            await _firmaAutodijelovaProvider.update(
                widget.firmaAutodijelova!.firmaAutodijelovaID,
                request);
          }
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        } on Exception {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) => const AlertDialog(
              title: Text("Greška"),
              content: Text( "Lozinke se ne podudaraju. Molimo unesite ispravne podatke"),
              actions: [
               
              ],
            ),
          );
        }
      }
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: const Text("Spasi"),
  ),


                        const SizedBox(width: 10),

                        // Dugme za bazu autoservisa
                        ElevatedButton(
  onPressed: () {
    // Navigacija na BPAutodijeloviAutoservisScreen i prosleđivanje objekta
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BPAutodijeloviAutoservisScreen(
          firmaAutodijelova: widget.firmaAutodijelova, // Prosleđivanje objekta
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // Crvena boja dugmeta
    foregroundColor: Colors.white, // Bijela boja teksta
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
              labelText: "Naziv firme",
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite naziv firme',
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
            ),
            style: const TextStyle(color: Colors.black),
            name: "nazivFirme",
            validator: validator.required,
            enabled: context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
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
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
            name: "adresa",
            validator: validator.required,
            enabled: context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
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
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                      child: Text(item.nazivGrada ?? "", style: const TextStyle(color: Colors.black)),
                    ))
                .toList() ?? [],
            enabled: context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
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
            decoration: const InputDecoration(
              labelText: "Telefon",
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite telefon',
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
            ),
            style: const TextStyle(color: Colors.black),
            name: "telefon",
            validator: validator.phoneNumber,
            enabled: context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
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
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
            enabled: context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
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
            decoration: const InputDecoration(
              labelText: "JIB",
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite JIB',
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
            ),
            style: const TextStyle(color: Colors.black),
            name: "jib",
            validator: validator.jib,
            enabled: context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
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
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
            enabled: context.read<UserProvider>().role == "Admin"|| context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID, // Enable if Admin
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Sakrivanje korisničkog imena, lozinke i ponovljene lozinke ako nije admin
    if (context.read<UserProvider>().role == "Admin" || context.read<UserProvider>().userId== widget.firmaAutodijelova!.firmaAutodijelovaID) ...[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Korisničko ime",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 5),
          FormBuilderTextField(
            decoration: const InputDecoration(
              labelText: "Korisničko ime",
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite korisničko ime',
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
            ),
            style: const TextStyle(color: Colors.black),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 5),
          FormBuilderTextField(
            decoration: const InputDecoration(
              labelText: "Lozinka",
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite lozinku',
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
            ),
            style: const TextStyle(color: Colors.black),
            name: "password",
            validator: validator.required,
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 5),
          FormBuilderTextField(
            decoration: const InputDecoration(
              labelText: "Ponovite lozinku",
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Ponovo unesite lozinku',
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
