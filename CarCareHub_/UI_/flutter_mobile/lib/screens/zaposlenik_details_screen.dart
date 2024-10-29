// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ZaposlenikDetailsScreen extends StatefulWidget {
  Zaposlenik? zaposlenik;
  ZaposlenikDetailsScreen({super.key, this.zaposlenik});

  @override
  State<ZaposlenikDetailsScreen> createState() => _ZaposlenikDetailsScreenState();
}

class _ZaposlenikDetailsScreenState extends State<ZaposlenikDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late ZaposlenikProvider _zaposlenikProvider;
  late GradProvider _gradProvider;
  late UlogeProvider _ulogeProvider;
  late AutoservisProvider _autoservisProvider;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;


  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogeResult;
  SearchResult<Autoservis>? autoservisResult;
  SearchResult<FirmaAutodijelova>? firmaAutodijelovaResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'ime': widget.zaposlenik?.ime,
      'prezime': widget.zaposlenik?.prezime,
      'maticniBroj': widget.zaposlenik?.maticniBroj,
      'brojTelefona': widget.zaposlenik?.brojTelefona,
      'gradId': widget.zaposlenik?.gradId,
      'datumRodjenja': widget.zaposlenik?.datumRodjenja,
      'email': widget.zaposlenik?.email,
      'username': widget.zaposlenik?.username,
      'password': widget.zaposlenik?.password,
      'ulogaId': widget.zaposlenik?.ulogaId,
      'autoservisId': widget.zaposlenik?.autoservisId,
      'firmaAutodijelovaId': widget.zaposlenik?.firmaAutodijelovaId,
    };

  

    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogeProvider = context.read<UlogeProvider>();
    _autoservisProvider = context.read<AutoservisProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    initForm();
  }

  Future initForm() async {

    gradResult = await _gradProvider.get();  
    ulogeResult = await _ulogeProvider.get(); 
    autoservisResult = await _autoservisProvider.get(); 
    firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get(); 

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
                      if (widget.zaposlenik == null) {
                        await _zaposlenikProvider.insert(request);
                      } else {
                        await _zaposlenikProvider.update(
                          widget.zaposlenik!.zaposlenikId!, 
                          _formKey.currentState?.value
                        );
                      }
                    } catch (e) {
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
                  child: const Text("Spasi"),
                ),
              ),
            ],
          ),
        ],
      ),
      title: widget.zaposlenik?.ime ?? "Detalji zaposlenika",
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValues,
      child: Column(
        children: [
          // Red 1
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Ime"),
                  name: "ime",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Prezime"),
                  name: "prezime",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Red 2
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Matični Broj"),
                  name: "maticniBroj",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Broj Telefona"),
                  name: "brojTelefona",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Red 3
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
                    hintText: 'grad',
                  ),
                  initialValue: widget.zaposlenik?.gradId != null
                      ? widget.zaposlenik!.gradId.toString()
                      : null, // Provjera za null vrijednosti
                  items: gradResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.gradId.toString(),
                                child: Text(item.nazivGrada ?? ""),
                              ))
                          .toList() ??
                      [], // Provjera za praznu listu //////////////////////////////////////////////////////
                ),
              ),
              Expanded(
              child: FormBuilderDateTimePicker(
                name: "datumRodjenja",
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: "Datum Rođenja"),
                initialValue: widget.zaposlenik?.datumRodjenja,
                format: DateFormat("dd.MM.yyyy"), // Format datuma
                onChanged: (value) {
                  // Ovdje možeš dodati logiku za promjenu
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

          // Red 4
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  name: "email",
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Username"),
                  name: "username",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Red 6
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Password"),
                  name: "password",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Red 7
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
                    hintText: 'uloge',
                  ),
                  initialValue: widget.zaposlenik?.ulogaId != null
                      ? widget.zaposlenik!.ulogaId.toString()
                      : null, // Provjera za null vrijednosti
                  items: ulogeResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.ulogaId.toString(),
                                child: Text(item.nazivUloge ?? ""),
                              ))
                          .toList() ??
                      [], // Provjera za praznu listu //////////////////////////////////////////////////////
                ),
              ),
              Expanded(
                child: FormBuilderDropdown(
                  name: 'autoservisId',
                  decoration: InputDecoration(
                    labelText: 'Autoservis',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['autoservisId']?.reset();
                      },
                    ),
                    hintText: 'autoservis',
                  ),
                  initialValue: widget.zaposlenik?.autoservisId != null
                      ? widget.zaposlenik!.autoservisId.toString()
                      : null, // Provjera za null vrijednosti
                  items: autoservisResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.autoservisId.toString(),
                                child: Text(item.naziv ?? ""),
                              ))
                          .toList() ??
                      [], // Provjera za praznu listu //////////////////////////////////////////////////////
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Red 8
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown(
                  name: 'firmaAutodijelovaID',
                  decoration: InputDecoration(
                    labelText: 'FirmaAutodijelova',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['firmaAutodijelovaID']?.reset();
                      },
                    ),
                    hintText: 'firmaautodijelova',
                  ),
                  initialValue: widget.zaposlenik?.firmaAutodijelovaId != null
                      ? widget.zaposlenik!.firmaAutodijelovaId.toString()
                      : null, // Provjera za null vrijednosti
                  items: firmaAutodijelovaResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.firmaAutodijelovaID.toString(),
                                child: Text(item.nazivFirme ?? ""),
                              ))
                          .toList() ??
                      [], // Provjera za praznu listu //////////////////////////////////////////////////////
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
