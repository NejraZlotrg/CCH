// ignore_for_file: must_be_immutable, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class UslugeDetailsScreen extends StatefulWidget {
  Usluge? usluge;
  UslugeDetailsScreen({super.key, this.usluge});

  @override
  State<UslugeDetailsScreen> createState() => _UslugeDetailsScreenState();
}

class _UslugeDetailsScreenState extends State<UslugeDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late UslugeProvider _uslugeProvider;

  bool isLoading = true;
  final validator = CreateValidator();

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivUsluge': widget.usluge?.nazivUsluge,
      'cijena': widget.usluge?.cijena.toString(),
      'opis': widget.usluge?.opis
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uslugeProvider = context.read<UslugeProvider>();
      initForm();
    });
  }

  Future initForm() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 204, 204, 204),
        appBar: AppBar(
          title: Text(widget.usluge?.nazivUsluge ?? "Detalji usluge"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator()
                          : _buildForm(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Potvrda brisanja"),
                                      content: const Text(
                                          "Da li ste sigurni da želite izbrisati ovu uslugu?"),
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
                                      await _uslugeProvider
                                          .delete(widget.usluge!.uslugeId);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Usluga uspješno izbrisana."),
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
                                  backgroundColor: Colors.red[700],
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
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Molimo popunite obavezna polja."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  if (_formKey.currentState
                                          ?.saveAndValidate() ??
                                      false) {
                                    var request =
                                        Map.from(_formKey.currentState!.value);
                                    try {
                                      if (widget.usluge == null) {
                                        await _uslugeProvider.insert(request);
                                      } else {
                                        await _uslugeProvider.update(
                                          widget.usluge!.uslugeId,
                                          request,
                                        );
                                      }

                                      Navigator.pop(context);
                                    } on Exception catch (e) {
                                      print("Greška pri čuvanju podataka: $e");
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text("Greška"),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } else {
                                    print("Forma nije validna!");
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
                      ),
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
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(
                    labelText: "Naziv usluge",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  name: "nazivUsluge",
                  validator: validator.required,
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
                    labelText: "Cijena usluge",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  name: "cijena",
                  validator: validator.required,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(
                    labelText: "Opis",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    alignLabelWithHint: true,
                  ),
                  name: "opis",
                  maxLines: 5,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  validator: validator.required,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
