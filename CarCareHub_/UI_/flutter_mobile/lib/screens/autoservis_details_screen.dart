import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/vozilo.dart'; // Dodaj model za vozilo
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart'; // Dodaj provider za vozilo
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AutoservisDetailsScreen extends StatefulWidget {
  Autoservis? autoservis;
  AutoservisDetailsScreen({super.key, this.autoservis});

  @override
  State<AutoservisDetailsScreen> createState() =>
      _AutoservisDetailsScreenState();
}

class _AutoservisDetailsScreenState extends State<AutoservisDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late AutoservisProvider _autoservisProvider;
  late GradProvider _gradProvider;
  late VoziloProvider _voziloProvider; // Vozilo provider

  SearchResult<Grad>? gradResult;
  SearchResult<Vozilo>? voziloResult; // Rezultat za vozila
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'naziv': widget.autoservis?.naziv ?? '',
      'korisnickoIme': widget.autoservis?.korisnickoIme ?? '',
      'adresa': widget.autoservis?.adresa ?? '',
      'vlasnikFirme': widget.autoservis?.vlasnikFirme ?? '',
      'telefon': widget.autoservis?.telefon ?? '',
      'email': widget.autoservis?.email ?? '',
      'jib': widget.autoservis?.jib ?? '',
      'mbs': widget.autoservis?.mbs ?? '',
      'ulogaId': widget.autoservis?.ulogaId?.toString() ?? '',
      'gradId': widget.autoservis?.gradId?.toString() ?? '',
      'voziloId': widget.autoservis?.voziloId?.toString() ?? '', // Dodano voziloId
    };

    _autoservisProvider = context.read<AutoservisProvider>();
    _gradProvider = context.read<GradProvider>();
    _voziloProvider = context.read<VoziloProvider>(); // Inicijalizacija vozilo providera
    initForm();
  }

  Future initForm() async {
    gradResult = await _gradProvider.get();
    voziloResult = await _voziloProvider.get(); // Dohvati vozila
    print(gradResult);
    print(voziloResult);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.autoservis?.naziv ?? "Detalji autoservisa",
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
                      if (widget.autoservis == null) {
                        await _autoservisProvider.insert(request);
                      } else {
                        await _autoservisProvider.update(
                            widget.autoservis!.autoservisId!,
                            _formKey.currentState?.value);
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
                  decoration: const InputDecoration(labelText: "Naziv"),
                  name: "naziv",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Korisničko ime"),
                  name: "korisnickoIme",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Adresa"),
                  name: "adresa",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Vlasnik firme"),
                  name: "vlasnikFirme",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Telefon"),
                  name: "telefon",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  name: "email",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "JIB"),
                  name: "jib",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "MBS"),
                  name: "mbs",
                ),
              ),
            ],
          ),
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
                    hintText: 'Grad',
                  ),
                  initialValue: widget.autoservis?.gradId?.toString(),
                  items: gradResult?.result
                          .map((grad) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: grad.gradId.toString(),
                                child: Text(grad.nazivGrada ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              ),
            ],
          ),
          Row(
            children: [
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
                    hintText: 'Vozilo',
                  ),
                  initialValue: widget.autoservis?.voziloId?.toString(),
                  items: voziloResult?.result
                          .map((vozilo) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: vozilo.voziloId.toString(),
                                child: Text(vozilo.markaVozila ?? ""),
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
