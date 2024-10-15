// ignore_for_file: sort_child_properties_last


import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ModelDetailsScreen extends StatefulWidget {
  Model? model;
  ModelDetailsScreen({super.key, this.model});

  @override
  State<ModelDetailsScreen> createState() => _ModelDetailsScreenState();
}

class _ModelDetailsScreenState extends State<ModelDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late ModelProvider _modelProvider;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivModela': widget.model?.nazivModela,
    };

    _modelProvider = context.read<ModelProvider>();
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
                      if (widget.model == null) {
                        await _modelProvider.insert(request);
                      } else {
                        await _modelProvider.update(
                            widget.model!.modelId!, _formKey.currentState?.value);
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
      title: widget.model?.nazivModela ?? "Detalji modela",
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
                  name: "nazivModela",
                ),
              ),
               Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "marka vozila"),
                  name: "marka vozila",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
