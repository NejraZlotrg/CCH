// ignore_for_file: sort_child_properties_last


import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/klijent.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
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

                    var request = Map.from(_formKey.currentState!.value);

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
                          title: const Text("error"),
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
                  decoration: const InputDecoration(labelText: "ime"),
                  name: "ime",
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "prezime"),
                  name: "prezime",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "username"),
                  name: "username",
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "email"),
                  name: "email",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "password"),
                  name: "password",
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "spol"),
                  name: "spol",
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "brojTelefona"),
                  name: "brojTelefona",
                ),
              ),
            ],
          ),
          /*Row(
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
                    hintText: 'grad',
                  ),
                  initialValue: widget.klijent?.gradId != null
                      ? widget.klijent!.gradId.toString()
                      : null, // Provjera za null vrijednosti
                  items: gradResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.gradIdtoString(),
                                child: Text(item.nazivGrada ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              )
            ],
          ),*/
        ],
      ),
    );
  }
}
