// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';

import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ZaposlenikDetailsScreen extends StatefulWidget {
  Zaposlenik? zaposlenik;
  ZaposlenikDetailsScreen({super.key, this.zaposlenik});

  @override
  State<ZaposlenikDetailsScreen> createState() => _ZaposlenikDetailsScreenState();
}

class _ZaposlenikDetailsScreenState extends State<ZaposlenikDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late ZaposlenikProvider _zaposlenikProvider;
  late GradProvider _gradProvider;
  late UlogeProvider _ulogeProvider;
  late AutoservisProvider _autoservisProvider;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;


  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogeResult;
  SearchResult<Autoservis>? autoservisResult;
  SearchResult<FirmaAutodijelova>? firmaAutodijelovaResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'ime': widget.zaposlenik?.ime,
      'prezime': widget.zaposlenik?.prezime,
      'maticniBroj': widget.zaposlenik?.maticniBroj,
      'brojTelefona': widget.zaposlenik?.brojTelefona,
      'gradId': widget.zaposlenik?.gradId,
      'datumRodjenja': widget.zaposlenik?.datumRodjenja,
      'email': widget.zaposlenik?.email,
      'username': widget.zaposlenik?.username,
      'password': widget.zaposlenik?.password,
      'ulogaId': widget.zaposlenik?.ulogaId,
      'autoservisId': widget.zaposlenik?.autoservisId,
      'firmaAutodijelovaId': widget.zaposlenik?.firmaAutodijelovaId,
      'passwordAgain': widget.zaposlenik?.passwordAgain,

    };

  

    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogeProvider = context.read<UlogeProvider>();
    _autoservisProvider = context.read<AutoservisProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    initForm();
  }

  Future initForm() async {

    gradResult = await _gradProvider.get();  
    ulogeResult = await _ulogeProvider.get(); 
    autoservisResult = await _autoservisProvider.get(); 
    firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get(); 

    setState(() {
      isLoading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
    appBar: AppBar(
      title: Text(widget.zaposlenik?.ime ?? "Detalji zaposlenika"),
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
                  onPressed: () async {
                    _formKey.currentState?.saveAndValidate();
                    var request = Map.from(_formKey.currentState!.value);


// Pretvorite datum u odgovarajući format (npr. ISO 8601)
if (request['datumRodjenja'] != null) {
  request['datumRodjenja'] = (request['datumRodjenja'] as DateTime).toIso8601String();
}

                    try {
                      if (widget.zaposlenik == null) {
                        await _zaposlenikProvider.insert(request);
                      } else {
                        await _zaposlenikProvider.update(
                          widget.zaposlenik!.zaposlenikId!, 
                          _formKey.currentState?.value
                        );
                      }
                    } catch (e) {
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
      
          const SizedBox(height: 8),
          ..._buildFormFields(),
        ],
      ),
    );
  }

List<Widget> _buildFormFields() {
  return [
    // Red 1: Ime i Prezime
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ime:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "ime",
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
                "Prezime:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "prezime",
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 2: Matični Broj i Broj Telefona
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Matični Broj:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "maticniBroj",
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
                "Broj Telefona:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "brojTelefona",
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 3: Grad i Datum Rođenja
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Grad:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderDropdown(
                name: 'gradId',
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
                              child: Text(item.nazivGrada ?? ""),
                            ))
                        .toList() ??
                    [],
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
                "Datum Rođenja:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
             FormBuilderDateTimePicker(
  name: "datumRodjenja",
  inputType: InputType.date,
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    fillColor: Colors.white,
    filled: true,
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    labelText: "Datum Rođenja",
  ),
  format: DateFormat("dd.MM.yyyy"),
  initialValue: _initialValues['datumRodjenja'], // Povezuje inicijalnu vrednost
)

            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 4: Email i Username
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Email:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                "Username:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "username",
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 5: Password i Password Again
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "password",
                obscureText: true,
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
                "Password Again:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderTextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                name: "passwordAgain",
                obscureText: true,
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Red 6: Uloga i Autoservis
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Uloga:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderDropdown(
                name: 'ulogaId',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  hintText: 'Izaberite ulogu',
                ),
                items: ulogeResult?.result
                        .map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: item.ulogaId.toString(),
                              child: Text(item.nazivUloge ?? ""),
                            ))
                        .toList() ??
                    [],
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
                "Autoservis:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderDropdown(
                name: 'autoservisId',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  hintText: 'Izaberite autoservis',
                ),
                items: autoservisResult?.result
                        .map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: item.autoservisId.toString(),
                              child: Text(item.naziv ?? ""),
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

    // Red 7: Firma Autodijelova
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Firma Autodijelova:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FormBuilderDropdown(
                name: 'firmaAutodijelovaID',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  hintText: 'Izaberite firmu',
                ),
                items: firmaAutodijelovaResult?.result
                        .map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: item.firmaAutodijelovaID.toString(),
                              child: Text(item.nazivFirme ?? ""),
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
  ];
}
}