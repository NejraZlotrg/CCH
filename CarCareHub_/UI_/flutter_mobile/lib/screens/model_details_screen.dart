import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
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
  late VoziloProvider _voziloProvider;
  late ModelProvider _modelProvider;
  SearchResult<Vozilo>? voziloResult;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivModela': widget.model?.nazivModela,
      'voziloId': widget.model?.vozilo.voziloId
    };

    _modelProvider = context.read<ModelProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    initForm();
  }

  Future<void> initForm() async {
    voziloResult = await _voziloProvider.get(); 
    print(voziloResult);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.model?.nazivModela ?? "Detalji modela",
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
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      var request = Map.from(_formKey.currentState!.value);

                      try {
                        if (widget.model == null) {
                          await _modelProvider.insert(request);
                        } else {
                          await _modelProvider.update(
                              widget.model!.modelId, request);
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
                    }
                  },
                  child: const Text("Spasi"),
                ),
              ),
            ],
          ),
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
                  decoration: const InputDecoration(labelText: "Naziv modela"),
                  name: "nazivModela",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Marka vozila"),
                  name: "markaVozila", // Novo polje za unos marke vozila
                  onChanged: (value) {
                    // Ovdje možeš dodati logiku za pretragu
                  },
                ),
              ),
              Expanded(
                child: FormBuilderDropdown(
                  name: 'voziloId',
                  decoration: InputDecoration(
                    labelText: 'Vozilo',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['voziloId']?.reset();
                      },
                    ),
                    hintText: 'Izaberi vozilo',
                  ),
                  initialValue: widget.model?.vozilo.voziloId != null
                      ? widget.model!.vozilo.voziloId.toString()
                      : null,
                  items: voziloResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.voziloId.toString(),
                                child: Text(item.markaVozila ?? ""),
                              ))
                          .toList() ?? [],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
