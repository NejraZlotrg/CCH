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
      child: Column(
        children: [
          _buildFilterForm(),
          Expanded(child: _buildDataListView()),
        ],
      ),
    );
  }

  Widget _buildFilterForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FormBuilderDateTimePicker(
                    name: 'odDatuma',
                    inputType: InputType.date,
                    decoration: const InputDecoration(labelText: 'Od datuma'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FormBuilderDateTimePicker(
                    name: 'doDatuma',
                    inputType: InputType.date,
                    decoration: const InputDecoration(labelText: 'Do datuma'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'kupacId',
                    decoration: const InputDecoration(labelText: 'Kupac ID'),
                    keyboardType: TextInputType.number,
                    enabled: !kupacDisabled,
                    onChanged: (value) => _onFieldChanged('kupacId', value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'zaposlenikId',
                    decoration: const InputDecoration(labelText: 'Zaposlenik ID'),
                    keyboardType: TextInputType.number,
                    enabled: !zaposlenikDisabled,
                    onChanged: (value) => _onFieldChanged('zaposlenikId', value),
                  ),
                ),
              ],
            ),
            FormBuilderTextField(
              name: 'autoservisId',
              decoration: const InputDecoration(labelText: 'Autoservis ID'),
              keyboardType: TextInputType.number,
              enabled: !autoservisDisabled,
              onChanged: (value) => _onFieldChanged('autoservisId', value),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  _loadData(_formKey.currentState!.value);
                }
              },
              child: const Text("Prikaži izvještaj"),
            ),
          ],
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