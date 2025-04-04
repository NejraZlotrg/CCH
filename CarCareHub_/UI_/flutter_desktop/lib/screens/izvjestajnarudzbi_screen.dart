import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/IzvjestajNarudzbi.dart';
import 'package:flutter_mobile/models/autoservisIzvjestaj.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';


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
  bool _isLoadingAutoservisReport = false;

String replaceDiacritics(String text) {
  return text
    .replaceAll('č', 'c')
    .replaceAll('ć', 'c')
    .replaceAll('ž', 'z')
    .replaceAll('š', 's')
    .replaceAll('đ', 'dj')
    .replaceAll('Č', 'C')
    .replaceAll('Ć', 'C')
    .replaceAll('Ž', 'Z')
    .replaceAll('Š', 'S')
    .replaceAll('Đ', 'DJ');
}


// Updated download function
Future<void> _downloadAutoservisReport() async {
  setState(() => _isLoadingAutoservisReport = true);
  
  try {
    final reportData = await _narudzbaProvider.getAutoservisIzvjestaj();
    final pdf = await _generatePdf(reportData);
    await _savePdfLocally(pdf, 'autoservis_izvjestaj_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(replaceDiacritics('Greska: $e'))),
    );
  } finally {
    setState(() => _isLoadingAutoservisReport = false);
  }
}
Future<pw.Document> _generatePdf(List<AutoservisIzvjestaj> reportData) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            replaceDiacritics('Izjestaj za autoservise (posljednjih 30 dana)'),
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        _buildPdfTable(reportData),
        pw.SizedBox(height: 20),
        pw.Text(
          replaceDiacritics('Generirano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    ),
  );

  return pdf;
}
 // Updated PDF table builder
pw.Widget _buildPdfTable(List<AutoservisIzvjestaj> reportData) {
  return pw.Table.fromTextArray(
    border: pw.TableBorder.all(),
    headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    cellAlignment: pw.Alignment.centerLeft,
    headerAlignment: pw.Alignment.centerLeft,
    data: [
      [
        replaceDiacritics('Autoservis'),
        replaceDiacritics('Broj narudzbi'),
        replaceDiacritics('Ukupan iznos'),
        replaceDiacritics('Prosj. cijena'),
        replaceDiacritics('Najpopularniji proizvodi')
      ],
      ...reportData.map((e) => [
        replaceDiacritics(e.nazivAutoservisa),
        e.brojNarudzbi.toString(),
        '${e.ukupanIznos.toStringAsFixed(2)} KM',
        '${e.prosjecnaCijena.toStringAsFixed(2)} KM',
        replaceDiacritics(e.najpopularnijiProizvodi.map((p) => '${p.naziv} (${p.ukupnaKolicina})').join(', '))
      ]).toList(),
    ],
  );
}

Future<void> _savePdfLocally(pw.Document pdf, String fileName) async {
  try {
    final directory = await getDownloadsDirectory();
    if (directory == null) throw Exception("Couldn't access downloads directory");
    
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(replaceDiacritics('PDF spremljen u: ${file.path}')),
        duration: const Duration(seconds: 5),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(replaceDiacritics('Greska pri spremanju: $e'))),
    );
  }
}

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
        kupacId: filter['kupacId'] != null ? int.tryParse(filter['kupacId'].toString()) : null,
        zaposlenikId: filter['zaposlenikId'] != null ? int.tryParse(filter['zaposlenikId'].toString()) : null,
        autoservisId: filter['autoservisId'] != null ? int.tryParse(filter['autoservisId'].toString()) : null,
      );
      setState(() {
        izvjestaji = data.cast<IzvjestajNarudzbi>();
      });
    } catch (e) {
      print('Greška prilikom učitavanja izvještaja: $e');
    }
  }

  

  void _onFieldChanged(String fieldName, dynamic value) {
    setState(() {
      final stringValue = value?.toString() ?? '';
      
      if (fieldName == 'kupacId' && stringValue.isNotEmpty) {
        zaposlenikDisabled = true;
        autoservisDisabled = true;
        _formKey.currentState?.fields['zaposlenikId']?.didChange(null);
        _formKey.currentState?.fields['autoservisId']?.didChange(null);
      } 
      else if (fieldName == 'zaposlenikId' && stringValue.isNotEmpty) {
        kupacDisabled = true;
        autoservisDisabled = true;
        _formKey.currentState?.fields['kupacId']?.didChange(null);
        _formKey.currentState?.fields['autoservisId']?.didChange(null);
      } 
      else if (fieldName == 'autoservisId' && stringValue.isNotEmpty) {
        kupacDisabled = true;
        zaposlenikDisabled = true;
        _formKey.currentState?.fields['kupacId']?.didChange(null);
        _formKey.currentState?.fields['zaposlenikId']?.didChange(null);
      } 
      else {
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
      child: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 204, 204, 204),
          child: Column(
            children: [
              _buildFilterForm(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingAutoservisReport ? null : _downloadAutoservisReport,
                    icon: _isLoadingAutoservisReport 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text("Download izvještaj za sve autoservise (30 dana)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildDataListView(),
            ],
          ),
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
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
                        decoration: const InputDecoration(
                          labelText: 'Od datuma',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FormBuilderDateTimePicker(
                        name: 'doDatuma',
                        inputType: InputType.date,
                        decoration: const InputDecoration(
                          labelText: 'Do datuma',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'kupacId',
                        decoration: const InputDecoration(
                          labelText: 'Kupac ID',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        valueTransformer: (value) => value != null ? int.tryParse(value) : null,
                        enabled: !kupacDisabled,
                        onChanged: (value) => _onFieldChanged('kupacId', value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'zaposlenikId',
                        decoration: const InputDecoration(
                          labelText: 'Zaposlenik ID',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        valueTransformer: (value) => value != null ? int.tryParse(value) : null,
                        enabled: !zaposlenikDisabled,
                        onChanged: (value) => _onFieldChanged('zaposlenikId', value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'autoservisId',
                  decoration: const InputDecoration(
                    labelText: 'Autoservis ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  valueTransformer: (value) => value != null ? int.tryParse(value) : null,
                  enabled: !autoservisDisabled,
                  onChanged: (value) => _onFieldChanged('autoservisId', value),
                ),
                const SizedBox(height: 20),
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
        ),
      ),
    );
  }

  Widget _buildDataListView() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Narudžba ID')),
            DataColumn(label: Text('Datum')),
            DataColumn(label: Text('Klijent')),
            DataColumn(label: Text('Autoservis')),
            DataColumn(label: Text('Zaposlenik')),
            DataColumn(label: Text('Ukupno')),
            DataColumn(label: Text('Status')),
          ],
          rows: izvjestaji.map((e) => DataRow(
            cells: [
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
            ],
          )).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}

