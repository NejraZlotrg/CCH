// ignore_for_file: sort_child_properties_last


import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';


import 'package:provider/provider.dart';

// ignore: must_be_immutable
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

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivDrzave': widget.usluge?.nazivUsluge,
    };

    _uslugeProvider = context.read<UslugeProvider>();
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
                      if (widget.usluge == null) {
                        await _uslugeProvider.insert(request);
                      } else {
                        await _uslugeProvider.update(
                            widget.usluge!.uslugeId, _formKey.currentState?.value);
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
      title: widget.usluge?.nazivUsluge ?? "Detalji drzave",
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
                  decoration: const InputDecoration(labelText: "naziv"),
                  name: "nazivUsluge",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
