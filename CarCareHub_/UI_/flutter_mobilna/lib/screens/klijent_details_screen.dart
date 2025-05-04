import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class KlijentDetailsScreen extends StatefulWidget {
  Klijent? klijent;
  KlijentDetailsScreen({super.key, this.klijent});

  @override
  State<KlijentDetailsScreen> createState() => _KlijentDetailsScreenState();
}

class _KlijentDetailsScreenState extends State<KlijentDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late KlijentProvider _klijentProvider;
  late GradProvider _gradProvider;
  bool _usernameExists = false;
  SearchResult<Grad>? gradResult;
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
      'gradId': widget.klijent?.gradId?.toString() ?? '',
      'ulogaId': widget.klijent?.ulogaId ?? '',
      'adresa' : widget.klijent?.adresa ?? '',
    };

    _klijentProvider = context.read<KlijentProvider>();
    _gradProvider = context.read<GradProvider>();

    initForm();
  }

  Future<void> initForm() async {
    if (context.read<UserProvider>().role == "Admin") {
      gradResult = await _gradProvider.getAdmin();
    } else {
      gradResult = await _gradProvider.get();
    }
    setState(() {
      isLoading = false;
    });
  }

 Future<void> _saveForm() async {
  // Provjera validacije forme
  if (!(_formKey.currentState?.validate() ?? false)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Molimo popunite obavezna polja."),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Provjera username-a
  final username = _formKey.currentState?.fields['username']?.value;
  if (username != null && username.toString().isNotEmpty) {
    final exists = await _klijentProvider.checkUsernameExists(username);
    if (exists && (widget.klijent == null || 
        widget.klijent?.username?.toLowerCase() != username.toLowerCase())) {
      setState(() {
        _usernameExists = true;
      });
      _formKey.currentState?.fields['username']?.validate();
      return;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.klijent?.ime ?? "Dodavanje klijenta"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                        if (!(context.read<UserProvider>().role == "Klijent" &&
          widget.klijent?.klijentId == 2))
                    const SizedBox(height: 20),
                    _buildForm(),
                                           
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // Prikaži dugme "Izbriši" samo ako nije Klijent s ID-om 2
    if (!(context.read<UserProvider>().role == "Admin" &&
        widget.klijent?.klijentId == 2))
   Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                    final userProvider = context.read<UserProvider>();
      final isOwnAccount = userProvider.role == "Klijent" &&
          userProvider.userId == widget.klijent?.klijentId;
                                // Potvrda brisanja
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Potvrda brisanja"),
                                    content: const Text(
                                        "Da li ste sigurni da želite izbrisati ovog klijenta?"),
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

                                // Ako korisnik potvrdi brisanje
                            if (confirmDelete == true) {
        try {
          await _klijentProvider.delete(widget.klijent!.klijentId);

          if (isOwnAccount) {
            // Logout i navigacija na login screen
         
         Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LogInPage(),
                  ),
                );
          } else {
            Navigator.pop(context); // Vrati se na prethodni ekran
          }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Klijent uspješno izbrisan."),
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
                                backgroundColor: Colors.red[700], // Crvena boja za brisanje
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
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _saveForm();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Molimo popunite obavezna polja")),
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
              FormBuilderTextField(
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Unesite ime',
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
              FormBuilderTextField(
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Unesite prezime',
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
                name: "prezime",
                validator: validator.required,
              ),
            ],
          ),
        ),
      ],
    ),

    // Red 2: Korisničko ime
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Korisničko ime",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
       FormBuilderTextField(
  decoration: const InputDecoration(
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
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    errorStyle: TextStyle(color: Colors.red),
  ),
  name: "username",
  validator: (value) {
    if (value == null || value.isEmpty || (value.length<3 || value.length>50)) {
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
      _formKey.currentState?.fields['username']?.validate();
    }
  },
),
      ],
    ),

    // Red 3: Lozinka
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lozinka",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          name: "password",
          validator: validator.password,
          obscureText: true,
        ),
      ],
    ),

    // Red 4: Ponovljena Lozinka
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ponovite lozinku",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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

    
 Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Adresa",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        FormBuilderTextField(
          decoration: const InputDecoration(
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
          name: "adresa",
          validator: validator.required,
        ),
      ],
    ),
    // Red 5: Grad
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Grad",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
                    color: item.vidljivo == false ? Colors.red : Colors.black,
                  ),
                ),
              ))
          .toList() ??
      [],
)

      ],
    ),

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
              FormBuilderTextField(
                decoration: const InputDecoration(
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
              FormBuilderTextField(
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Unesite broj telefona',
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
                name: "brojTelefona",
                validator: validator.phoneNumber,
              ),
            ],
          ),
        ),
      ],
    ),

    // Red 7: Spol
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
              FormBuilderTextField(
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Unesite spol',
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
                name: "spol",
                validator: validator.required,
              ),
            ],
          ),
        ),
      ],
    ),
  ];
}

  }

