import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/provider/proizvodjac_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
 
// ignore: must_be_immutable
class ProizvodjacDetailsScreen extends StatefulWidget {
  Proizvodjac? proizvodjac;
  ProizvodjacDetailsScreen({super.key, this.proizvodjac});
 
  @override
  State<ProizvodjacDetailsScreen> createState() =>
      _ProizvodjacDetailsScreenState();
}
 
class _ProizvodjacDetailsScreenState extends State<ProizvodjacDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late ProizvodjacProvider _proizvodjacProvider;
 
  bool isLoading = true;

  final validator = CreateValidator();
 
  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivProizvodjaca': widget.proizvodjac?.nazivProizvodjaca,
    };
 
    _proizvodjacProvider = context.read<ProizvodjacProvider>();
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
        backgroundColor:
            const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
        appBar: AppBar(
          title: Text(widget.proizvodjac?.nazivProizvodjaca ?? "Detalji proizvodjaca"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                              if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo popunite obavezna polja."),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Zaustavi obradu ako validacija nije prošla
    }
                          _formKey.currentState?.saveAndValidate();
 
                          var request = Map.from(_formKey.currentState!.value);
 
                          try {
                            if (widget.proizvodjac == null) {
                              await _proizvodjacProvider.insert(request);
                            } else {
                              await _proizvodjacProvider.update(
                                widget.proizvodjac!.proizvodjacId!,
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
              )
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
                child: FormBuilderTextField(
                  decoration: const InputDecoration(
                    labelText: "Naziv proizvođača",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  name: "nazivProizvodjaca",
                  validator: validator.required,
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
 
 