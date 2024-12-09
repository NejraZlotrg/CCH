import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/godiste.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
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
  SearchResult<Godiste>? godisteResult;
  late GodisteProvider _godisteProvider;
 
  bool isLoading = true;
 
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
    voziloResult = await _voziloProvider.get();
    godisteResult = await _godisteProvider.get();
    setState(() {
      isLoading = false;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.model?.nazivModela ?? "Detalji modela",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              isLoading ? const CircularProgressIndicator() : _buildForm(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
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
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown(
                  name: 'voziloId',
                  decoration: InputDecoration(
                    labelText: 'Vozilo',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    suffix: IconButton(
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
                                child: Text(item.markaVozila ?? ""),
                              ))
                          .toList() ?? [],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FormBuilderTextField(
                  name: "nazivModela",
                  decoration: const InputDecoration(
                    labelText: "Naziv modela",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FormBuilderDropdown(
                  name: 'godisteId',
                  decoration: InputDecoration(
                    labelText: 'Godiste',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    suffix: IconButton(
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
                                child: Text(item.godiste_.toString()),
                              ))
                          .toList() ?? [],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
 