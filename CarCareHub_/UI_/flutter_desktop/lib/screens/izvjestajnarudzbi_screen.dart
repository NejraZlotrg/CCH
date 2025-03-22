import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/IzvjestajNarudzbi.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IzvjestajNarudzbiScreen extends StatefulWidget {
  const IzvjestajNarudzbiScreen({super.key});

  @override
  State<IzvjestajNarudzbiScreen> createState() => _IzvjestajNarudzbiScreenState();
}

class _IzvjestajNarudzbiScreenState extends State<IzvjestajNarudzbiScreen> {
  late NarudzbaProvider _narudzbaProvider;
  List<IzvjestajNarudzbi> izvjestaji = [];
  final _formKey = GlobalKey<FormBuilderState>();

  bool kupacDisabled = false;
  bool zaposlenikDisabled = false;
  bool autoservisDisabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaProvider = context.read<NarudzbaProvider>();
  }

  Future<void> _loadData(Map<String, dynamic> filter) async {
    try {
      var data = await _narudzbaProvider.getIzvjestaj(
        odDatuma: filter['odDatuma'],
        doDatuma: filter['doDatuma'],
        kupacId: filter['kupacId'],
        zaposlenikId: filter['zaposlenikId'],
        autoservisId: filter['autoservisId'],
      );
      setState(() {
        izvjestaji = data.cast<IzvjestajNarudzbi>();
      });
    } catch (e) {
      print('Greška prilikom učitavanja izvještaja: $e');
    }
  }

  void _onFieldChanged(String fieldName, String? value) {
    setState(() {
      if (fieldName == 'kupacId' && value!.isNotEmpty) {
        zaposlenikDisabled = true;
        autoservisDisabled = true;
      } else if (fieldName == 'zaposlenikId' && value!.isNotEmpty) {
        kupacDisabled = true;
        autoservisDisabled = true;
      } else if (fieldName == 'autoservisId' && value!.isNotEmpty) {
        kupacDisabled = true;
        zaposlenikDisabled = true;
      } else {
        kupacDisabled = false;
        zaposlenikDisabled = false;
        autoservisDisabled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Izvještaj narudžbi",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
        child: Column(
          children: [
          _buildFilterForm(),
          Expanded(child: _buildDataListView()),
        ],
        ),
      ),
    );
  }

 Widget _buildFilterForm() {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
       
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Datumski odabir
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'odDatuma',
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        labelText: 'Od datuma',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'doDatuma',
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        labelText: 'Do datuma',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Kupac ID i Zaposlenik ID
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'kupacId',
                      decoration: InputDecoration(
                        labelText: 'Kupac ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !kupacDisabled,
                      onChanged: (value) => _onFieldChanged('kupacId', value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'zaposlenikId',
                      decoration: InputDecoration(
                        labelText: 'Zaposlenik ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !zaposlenikDisabled,
                      onChanged: (value) => _onFieldChanged('zaposlenikId', value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Autoservis ID
              FormBuilderTextField(
                name: 'autoservisId',
                decoration: InputDecoration(
                  labelText: 'Autoservis ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                enabled: !autoservisDisabled,
                onChanged: (value) => _onFieldChanged('autoservisId', value),
              ),
              const SizedBox(height: 20),

              // Gumb za prikaz izvještaja
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    _loadData(_formKey.currentState!.value);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800, // Tamnocrvena boja
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  elevation: 5,
                ),
                child: const Text(
                  "Prikaži izvještaj",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDataListView() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Narudžba ID')),
              DataColumn(label: Text('Datum narudžbe')),
              DataColumn(label: Text('Klijent')),
              DataColumn(label: Text('Autoservis')),
              DataColumn(label: Text('Zaposlenik')),
              DataColumn(label: Text('Ukupna cijena')),
              DataColumn(label: Text('Status')),
            ],
            rows: izvjestaji
                .map(
                  (e) => DataRow(cells: [
                    DataCell(Text(e.narudzbaId.toString())),
                    DataCell(Text(e.datumNarudzbe != null ? _formatDate(e.datumNarudzbe!) : 'N/A')),
                    DataCell(Text(e.klijent?.ime ?? 'N/A')),
                    DataCell(Text(e.autoservis?.naziv ?? 'N/A')),
                    DataCell(Text(e.zaposlenik?.ime ?? 'N/A')),
                    DataCell(Text(e.ukupnaCijena != null ? '${e.ukupnaCijena!.toStringAsFixed(2)} KM' : 'N/A')),
                    DataCell(Icon(
                      e.status == true ? Icons.check_circle : Icons.cancel,
                      color: e.status == true ? Colors.green : Colors.red,
                    )),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}