// ignore_for_file: sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class VoziloDetailsScreen extends StatefulWidget {
  Vozilo? vozilo;
  VoziloDetailsScreen({super.key, this.vozilo});

  @override
  State<VoziloDetailsScreen> createState() => _VoziloDetailsScreenState();
}

class _VoziloDetailsScreenState extends State<VoziloDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late VoziloProvider _voziloProvider;

  bool isLoading = true;
  final validator = CreateValidator();
  @override
  void initState() {
    super.initState();
    _initialValues = {
      'markaVozila': widget.vozilo?.markaVozila,
    };

    _voziloProvider = context.read<VoziloProvider>();
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
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.vozilo?.markaVozila ?? "Detalji vozila"),
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
                                        "Da li ste sigurni da želite izbrisati ovo vozilo?"),
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
                                    await _voziloProvider
                                        .delete(widget.vozilo!.voziloId!);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Vozilo uspješno izbrisano."),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                _formKey.currentState?.saveAndValidate();

                                var request =
                                    Map.from(_formKey.currentState!.value);

                                try {
                                  if (widget.vozilo == null) {
                                    await _voziloProvider.insert(request);
                                  } else {
                                    await _voziloProvider.update(
                                      widget.vozilo!.voziloId!,
                                      _formKey.currentState?.value,
                                    );
                                  }
                                  Navigator.pop(context);
                                } on Exception catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text("Error"),
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
              labelText: "Marka vozila",
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
            name: "markaVozila",
            validator: validator.required,
          ))
        ],
      ),
      const SizedBox(height: 20),
    ];
  }
}
