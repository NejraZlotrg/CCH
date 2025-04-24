// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DrzaveDetailsScreen extends StatefulWidget {
  Drzave? drzava;
  DrzaveDetailsScreen({super.key, this.drzava});

  @override
  State<DrzaveDetailsScreen> createState() => _DrzaveDetailsScreenState();
}

class _DrzaveDetailsScreenState extends State<DrzaveDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late DrzaveProvider _drzaveProvider;

  bool isLoading = true;

  final validator = CreateValidator();

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivDrzave': widget.drzava?.nazivDrzave,
    };

    _drzaveProvider = context.read<DrzaveProvider>();
    initForm();
  }

  Future initForm() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
        appBar: AppBar(
          title: Text(widget.drzava?.nazivDrzave ?? "Detalji drzave"),
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
                            if (widget.drzava != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Potvrda brisanja
                                    bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Potvrda brisanja"),
                                        content: const Text(
                                            "Da li ste sigurni da želite izbrisati ovu državu?"),
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
                                        await _drzaveProvider
                                            .delete(widget.drzava!.drzavaId!);
                                        Navigator.pop(
                                            context); // Vrati se na prethodni ekran
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Država uspješno izbrisana."),
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
                                    backgroundColor: Colors
                                        .red[700], // Crvena boja za brisanje
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
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Provjera validacije forme
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Molimo popunite obavezna polja."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return; // Zaustavi obradu ako validacija nije prošla
                                  }
                                  _formKey.currentState?.saveAndValidate();

                                  var request =
                                      Map.from(_formKey.currentState!.value);

                                  try {
                                    if (widget.drzava == null) {
                                      await _drzaveProvider.insert(request);
                                    } else {
                                      await _drzaveProvider.update(
                                          widget.drzava!.drzavaId!,
                                          _formKey.currentState?.value);
                                    }
                                    Navigator.pop(context);
                                  } on Exception catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text("error"),
                                        content: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK"),
                                          )
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
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValues,
      child: Column(
        children: [
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
                    labelText: "Naziv drzave",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white, // Bela pozadina
                    filled: true, // Da pozadina bude ispunjena
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: validator.required,
                  name: "nazivDrzave")),
        ],
      ),
      const SizedBox(height: 20),
    ];
  }
}
