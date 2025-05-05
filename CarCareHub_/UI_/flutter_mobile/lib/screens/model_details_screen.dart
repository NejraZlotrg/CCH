// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ModelDetailsScreen extends StatefulWidget {
  Model? model;
  ModelDetailsScreen({super.key, this.model});

  @override
  State<ModelDetailsScreen> createState() => _ModelDetailsScreenState();
}

class _ModelDetailsScreenState extends State<ModelDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late VoziloProvider _voziloProvider;
  late ModelProvider _modelProvider;
  SearchResult<Vozilo>? voziloResult;
  SearchResult<Godiste>? godisteResult;
  late GodisteProvider _godisteProvider;

  bool isLoading = true;

  final validator = CreateValidator();
  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivModela': widget.model?.nazivModela,
      'voziloId': widget.model?.vozilo?.voziloId,
      'godisteId': widget.model?.godiste?.godisteId
    };

    _modelProvider = context.read<ModelProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _godisteProvider = context.read<GodisteProvider>();
    initForm();
  }

  Future<void> initForm() async {
    if (context.read<UserProvider>().role == "Admin") {
      voziloResult = await _voziloProvider.getAdmin();
      godisteResult = await _godisteProvider.getAdmin();
    } else {
      voziloResult = await _voziloProvider.get();
      godisteResult = await _godisteProvider.get();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.model?.nazivModela ?? "Detalji modela"),
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
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Potvrda brisanja"),
                                    content: const Text(
                                        "Da li ste sigurni da želite izbrisati ovaj model?"),
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
                                    await _modelProvider
                                        .delete(widget.model!.modelId);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Model uspješno izbrisan."),
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
                          ElevatedButton(
                            onPressed: () async {
                              if (!(_formKey.currentState?.validate() ??
                                  false)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Molimo popunite obavezna polja."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                var request =
                                    Map.from(_formKey.currentState!.value);

                                try {
                                  if (widget.model == null) {
                                    await _modelProvider.insert(request);
                                  } else {
                                    await _modelProvider.update(
                                        widget.model!.modelId, request);
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
                                        )
                                      ],
                                    ),
                                  );
                                }
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
          const SizedBox(height: 20),
          const Center(),
          const SizedBox(height: 20),
          ..._buildFormFields(),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      FormBuilderDropdown(
        name: 'voziloId',
        validator: validator.required,
        decoration: InputDecoration(
          labelText: 'Vozilo',
          border: const OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _formKey.currentState!.fields['voziloId']?.reset();
            },
          ),
        ),
        initialValue: widget.model?.vozilo?.voziloId != null
            ? widget.model!.vozilo?.voziloId.toString()
            : null,
        items: voziloResult?.result
                .map((item) => DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: item.voziloId.toString(),
                      child: Text(
                        item.markaVozila ?? "",
                        style: TextStyle(
                          color: item.vidljivo == false
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ))
                .toList() ??
            [],
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        name: "nazivModela",
        validator: validator.required,
        decoration: const InputDecoration(
          labelText: "Naziv modela",
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
      const SizedBox(height: 10),
      FormBuilderDropdown(
        name: 'godisteId',
        validator: validator.required,
        decoration: InputDecoration(
          labelText: 'Godište',
          border: const OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _formKey.currentState!.fields['godisteId']?.reset();
            },
          ),
        ),
        initialValue: widget.model?.godiste?.godisteId != null
            ? widget.model!.godiste?.godisteId.toString()
            : null,
        items: godisteResult?.result
                .map((item) => DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: item.godisteId.toString(),
                      child: Text(
                        item.godiste_.toString(),
                        style: TextStyle(
                          color: item.vidljivo == false
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ))
                .toList() ??
            [],
      ),
      const SizedBox(height: 10),
    ];
  }
}
