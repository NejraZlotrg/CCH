// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/vozilo.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class KlijentDetailsScreen extends StatefulWidget {
  Klijent? klijent;
  KlijentDetailsScreen({Key? key, this.klijent}) : super(key: key);

  @override
  State<KlijentDetailsScreen> createState() => _KlijentDetailsScreenState();
}

class _KlijentDetailsScreenState extends State<KlijentDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late KlijentProvider _klijentProvider;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'klijent': widget.klijent?.klijentId,
      'ime': widget.klijent?.ime,
      'prezime': widget.klijent?.prezime,
      'username': widget.klijent?.username,
      'email': widget.klijent?.email,
      'password': widget.klijent?.password,
      'lozinkaSalt': widget.klijent?.lozinkaSalt,
      'lozinkaHash': widget.klijent?.lozinkaHash,
      'spol': widget.klijent?.spol,
      'brojTelefona': widget.klijent?.brojTelefona?.toString(),
      'gradId': widget.klijent?.gradId?.toString(),
    };

    _klijentProvider = context.read<KlijentProvider>();
    initForm();
  }

  Future initForm() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
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

                    var request = new Map.from(_formKey.currentState!.value);

                    try {
                      if (widget.klijent == null) {
                        await _klijentProvider.insert(request);
                      } else {
                        await _klijentProvider.update(
                            widget.klijent!.klijentId!, _formKey.currentState?.value);
                      }
                    } on Exception catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text("error"),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: Text("Spasi"),
                ),
              ),
            ],
          )
        ],
      ),
      title: widget.klijent?.ime ?? "Detalji Proizvoda",
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
                  decoration: const InputDecoration(labelText: "klijentId"),
                  name: "klijentId",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "ime"),
                  name: "ime",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "prezime"),
                  name: "prezime",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "username"),
                  name: "username",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "email"),
                  name: "email",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "password"),
                  name: "password",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "lozinkaSalt"),
                  name: "lozinkaSalt",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "lozinkaHash"),
                  name: "lozinkaHash",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "spol"),
                  name: "spol",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "brojTelefona"),
                  name: "brojTelefona",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "gradId"),
                  name: "gradId",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
