import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class KlijentRegistracijaScreen extends StatefulWidget {
  Klijent? klijent;
  KlijentRegistracijaScreen({super.key, this.klijent});

  @override
  State<KlijentRegistracijaScreen> createState() =>
      _KlijentRegistracijaScreenState();
}

class _KlijentRegistracijaScreenState
    extends State<KlijentRegistracijaScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late KlijentProvider _klijentProvider;
  late GradProvider _gradProvider;

  SearchResult<Grad>? gradResult;


  List<Usluge> usluge = [];
  bool isLoading = true;

  final validator = CreateValidator();

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'ime': widget.klijent?.ime ?? '',
      'prezime': widget.klijent?.prezime ?? '',
      'email': widget.klijent?.email ?? '',
      'username': widget.klijent?.username ?? '',
      'password': widget.klijent?.password ?? '',
      'passwordAgain': widget.klijent?.passwordAgain ?? '',
      'spol': widget.klijent?.spol ?? '',
      'brojTelefona': widget.klijent?.brojTelefona ?? '',
      'gradId': widget.klijent?.gradId ?? '',
      'ulogaId': widget.klijent?.ulogaId ?? '',

    };

    _klijentProvider = context.read<KlijentProvider>();
    _gradProvider = context.read<GradProvider>();

    initForm();
  }

  Future initForm() async {
    gradResult = await _gradProvider.get();

    setState(() {
      isLoading = false;
    });
  }

  


  Future<void> _saveForm() async {
    _formKey.currentState?.saveAndValidate();
    var request = Map.from(_formKey.currentState!.value);

      request['ulogaId'] = 4;

    try {
      if (widget.klijent == null) {
        await _klijentProvider.insert(request);
      } else {
        await _klijentProvider.update(
          widget.klijent!.klijentId,
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
        title: Text(widget.klijent?.ime ?? "Registracija novog klijenta"),
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
                            onPressed: ()  {
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
                "Ime:",
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
                name: "ime",
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
                "Prezime:",
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
                name: "prezime",
                validator: validator.required,
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
        const SizedBox(width: 20),


        
          
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
                "Spol:",
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
                name: "spol",
                validator: validator.required,
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