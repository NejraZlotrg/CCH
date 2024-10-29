import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';

class FirmaAutodijelovaDetailScreen extends StatefulWidget {
  final FirmaAutodijelova? firmaAutodijelova;
  const FirmaAutodijelovaDetailScreen({super.key, this.firmaAutodijelova});

  @override
  State<FirmaAutodijelovaDetailScreen> createState() => _FirmaAutodijelovaDetailScreenState();
}

class _FirmaAutodijelovaDetailScreenState extends State<FirmaAutodijelovaDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  late GradProvider _gradProvider;
  late UlogeProvider _ulogaProvider;
  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogaResult;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivFirme': widget.firmaAutodijelova?.nazivFirme,
      'gradId': widget.firmaAutodijelova?.gradId,
      'ulogaId': widget.firmaAutodijelova?.ulogaId,
    };

    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogaProvider = context.read<UlogeProvider>();

    initForm();
  }

  Future<void> initForm() async {
    gradResult = await _gradProvider.get();
    ulogaResult = await _ulogaProvider.get();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.firmaAutodijelova?.nazivFirme ?? "Detalji firme",
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.saveAndValidate();

                    var request = Map.from(_formKey.currentState!.value);

                    try {
                      if (widget.firmaAutodijelova == null) {
                        await _firmaAutodijelovaProvider.insert(request);
                      } else {
                        await _firmaAutodijelovaProvider.update(
                            widget.firmaAutodijelova!.firmaAutodijelovaID!, _formKey.currentState?.value);
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
                  },
                  child: const Text("Spasi"),
                ),
              ),
            ],
          )
        ],
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
                  decoration: const InputDecoration(labelText: "Naziv firme"),
                  name: "nazivFirme",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Adresa"),
                  name: "adresa",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
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
                    hintText: 'Izaberite grad',
                  ),
                  initialValue: widget.firmaAutodijelova?.gradId != null
                      ? widget.firmaAutodijelova!.gradId.toString()
                      : null,
                  items: gradResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.gradId.toString(),
                                child: Text(item.nazivGrada ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "JIB"),
                  name: "jib",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "MBS"),
                  name: "mbs",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Telefon"),
                  name: "telefon",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  name: "email",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Password"),
                  name: "password",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Slika profila"),
                  name: "slikaProfila",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown(
                  name: 'ulogaId',
                  decoration: InputDecoration(
                    labelText: 'Uloge',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['ulogaId']?.reset();
                      },
                    ),
                    hintText: 'Izaberite ulogu',
                  ),
                  initialValue: widget.firmaAutodijelova?.ulogaId != null
                      ? widget.firmaAutodijelova!.ulogaId.toString()
                      : null,
                  items: ulogaResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.ulogaId.toString(),
                                child: Text(item.nazivUloge ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
