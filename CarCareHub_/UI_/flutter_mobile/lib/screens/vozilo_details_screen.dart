// ignore_for_file: sort_child_properties_last
 
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
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
    return MasterScreenWidget(
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
                          _formKey.currentState?.saveAndValidate();
 
                          var request = Map.from(_formKey.currentState!.value);
 
                          try {
                            if (widget.vozilo == null) {
                              await _voziloProvider.insert(request);
                            } else {
                              await _voziloProvider.update(
                                widget.vozilo!.voziloId!,
                                _formKey.currentState?.value,
                              );
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
      title: widget.vozilo?.markaVozila ?? "Detalji vozila",
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
                  decoration: const InputDecoration(
                    labelText: "Marka vozila",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  name: "markaVozila",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
 
 