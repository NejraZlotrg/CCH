import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/usluge.dart'; // Dodaj model za usluge
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart'; // Dodaj provider za usluge
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AutoservisDetailsScreen extends StatefulWidget {
  Autoservis? autoservis;
  AutoservisDetailsScreen({super.key, this.autoservis});

  @override
  State<AutoservisDetailsScreen> createState() => _AutoservisDetailsScreenState();
}

class _AutoservisDetailsScreenState extends State<AutoservisDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late AutoservisProvider _autoservisProvider;
  late UslugeProvider _uslugaProvider; // Provider za usluge
  late GradProvider _gradProvider;

  SearchResult<Grad>? gradResult;
  List<Usluge> usluge = []; // Lista usluga za prikaz
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
    };

    _autoservisProvider = context.read<AutoservisProvider>();
    _uslugaProvider = context.read<UslugeProvider>(); // Inicijalizacija provider-a za usluge
    _gradProvider = context.read<GradProvider>();
    
    initForm();
    fetchUsluge(); // Dohvati usluge povezane s autoservisom
  }

  Future initForm() async {
    gradResult = await _gradProvider.get();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchUsluge() async {
    usluge = await _uslugaProvider.getById(widget.autoservis?.autoservisId ?? 0);
    setState(() {}); // Osvježi ekran kako bi prikazao dohvaćene usluge
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.autoservis?.naziv ?? "Detalji autoservisa",
      child: SingleChildScrollView( 
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(),
          // Tabela za prikaz usluga
          Padding(
            padding: const EdgeInsets.all(10),
            child: usluge.isNotEmpty
                ? DataTable(
                    columns: const [
                      DataColumn(label: Text("Naziv usluge")),
                      DataColumn(label: Text("Cijena")),
                      DataColumn(label: Text("Opis")),
                    ],
                    rows: usluge.map((usluga) {
                      return DataRow(
                        cells: [
                          DataCell(Text(usluga.nazivUsluge ?? "")),
                          DataCell(Text(usluga.cijena?.toString() ?? "")),
                          DataCell(Text(usluga.opis ?? "")),
                        ],
                      );
                    }).toList(),
                  )
                : const Text("Nema dostupnih usluga za ovaj autoservis."),
          ),
          // Dugme za dodavanje nove usluge
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () => _showAddUslugaDialog(),
              child: const Text("Dodaj uslugu"),
            ),
          ),
          // Ostali dijelovi
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                   onPressed: () async {
                      _formKey.currentState?.save();
                      var request = Map.from(_formKey.currentState!.value);

                      try {
                        if (widget.autoservis == null) {
                          await _autoservisProvider.insert(request);
                        } else {
                          await _autoservisProvider.update(
                              widget.autoservis!.autoservisId!,
                              request);
                        }
                        Navigator.pop(context);
                      } on Exception catch (e) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Greška"),
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
          )
        ],
      ),
      )
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
        ],
      ),
    );
  }

  // Dijalog za dodavanje nove usluge
  void _showAddUslugaDialog() {
    final uslugaFormKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Dodaj novu uslugu"),
          content: FormBuilder(
            key: uslugaFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: "nazivUsluge",
                  decoration: const InputDecoration(labelText: "Naziv usluge"),
                ),
                FormBuilderTextField(
                  name: "cijena",
                  decoration: const InputDecoration(labelText: "Cijena"),
                  keyboardType: TextInputType.number,
                ),
                FormBuilderTextField(
                  name: "opis",
                  decoration: const InputDecoration(labelText: "Opis"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Odustani"),
            ),
            TextButton(
              onPressed: () async {
                uslugaFormKey.currentState?.saveAndValidate();
                var uslugaRequest = Map.from(uslugaFormKey.currentState!.value);
                uslugaRequest['autoservisId'] = widget.autoservis?.autoservisId;

                try {
                  await _uslugaProvider.insert(uslugaRequest);
                  Navigator.pop(context);
                  fetchUsluge(); // Osvježi usluge nakon dodavanja nove
                } on Exception catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Greška"),
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
              child: const Text("Dodaj"),
            ),
          ],
        );
      },
    );
  }
}