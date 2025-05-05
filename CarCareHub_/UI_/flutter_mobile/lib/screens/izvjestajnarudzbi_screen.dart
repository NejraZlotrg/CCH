// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/IzvjestajNarudzbi.dart';
import 'package:flutter_mobile/models/autoservisIzvjestaj.dart';
import 'package:flutter_mobile/models/klijentIzvjestaj.dart';
import 'package:flutter_mobile/models/zaposlenikIzvjestaj.dart';
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
  State<IzvjestajNarudzbiScreen> createState() =>
      _IzvjestajNarudzbiScreenState();
}

class _IzvjestajNarudzbiScreenState extends State<IzvjestajNarudzbiScreen> {
  late NarudzbaProvider _narudzbaProvider;
  List<IzvjestajNarudzbi> izvjestaji = [];
  final _formKey = GlobalKey<FormBuilderState>();

  bool kupacDisabled = false;
  bool zaposlenikDisabled = false;
  bool autoservisDisabled = false;
  bool _isLoadingAutoservisReport = false;
  bool _isLoadingKlijentiReport = false;
  bool _isLoadingZaposleniciReport = false;

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

  Future<void> _downloadAutoservisReport() async {
    setState(() => _isLoadingAutoservisReport = true);
    try {
      final reportData = await _narudzbaProvider.getAutoservisIzvjestaj();
      final pdf = await _generateAutoservisPdf(reportData);
      await _savePdfLocally(pdf,
          'autoservis_izvjestaj_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(replaceDiacritics('Greska: $e'))),
      );
    } finally {
      setState(() => _isLoadingAutoservisReport = false);
    }
  }

  Future<void> _downloadKlijentiReport() async {
    setState(() => _isLoadingKlijentiReport = true);
    try {
      final reportData = await _narudzbaProvider.getKlijentIzvjestaj();
      final pdf = await _generateKlijentiPdf(reportData);
      await _savePdfLocally(pdf,
          'klijenti_izvjestaj_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(replaceDiacritics('Greska: $e'))),
      );
    } finally {
      setState(() => _isLoadingKlijentiReport = false);
    }
  }

  Future<pw.Document> _generateCurrentDataPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              replaceDiacritics('Izvještaj narudžbi'),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildCurrentDataPdfTable(),
          pw.SizedBox(height: 20),
          pw.Text(
            replaceDiacritics(
                'Generirano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildCurrentDataPdfTable() {
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      data: [
        [
          replaceDiacritics('Datum'),
          replaceDiacritics('Klijent'),
          replaceDiacritics('Autoservis'),
          replaceDiacritics('Zaposlenik'),
          replaceDiacritics('Ukupno'),
          replaceDiacritics('Status')
        ],
        ...izvjestaji.map((e) => [
              replaceDiacritics(e.datumNarudzbe != null
                  ? _formatDate(e.datumNarudzbe!)
                  : 'N/A'),
              replaceDiacritics(e.klijent?.ime ?? 'N/A'),
              replaceDiacritics(e.autoservis?.naziv ?? 'N/A'),
              replaceDiacritics(e.zaposlenik?.ime ?? 'N/A'),
              '${e.ukupnaCijena?.toStringAsFixed(2) ?? '0.00'} KM',
              e.status == true ? 'Da' : 'Ne'
            ]),
      ],
    );
  }

  bool _isLoadingCurrentReport = false;

  Future<void> _downloadCurrentReport() async {
    if (izvjestaji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nema podataka za preuzimanje')),
      );
      return;
    }

    setState(() => _isLoadingCurrentReport = true);
    try {
      final pdf = await _generateCurrentDataPdf();
      await _savePdfLocally(pdf,
          'izvjestaj_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(replaceDiacritics('Greška: $e'))),
      );
    } finally {
      setState(() => _isLoadingCurrentReport = false);
    }
  }

  Future<void> _downloadZaposleniciReport() async {
    setState(() => _isLoadingZaposleniciReport = true);
    try {
      final reportData = await _narudzbaProvider.getZaposlenikIzvjestaj();
      final pdf = await _generateZaposleniciPdf(reportData);
      await _savePdfLocally(pdf,
          'zaposlenici_izvjestaj_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(replaceDiacritics('Greska: $e'))),
      );
    } finally {
      setState(() => _isLoadingZaposleniciReport = false);
    }
  }

  Future<pw.Document> _generateAutoservisPdf(
      List<AutoservisIzvjestaj> reportData) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              replaceDiacritics(
                  'Izjestaj za autoservise (posljednjih 30 dana)'),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildAutoservisPdfTable(reportData),
          pw.SizedBox(height: 20),
          pw.Text(
            replaceDiacritics(
                'Generirano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
    return pdf;
  }

  Future<pw.Document> _generateKlijentiPdf(
      List<KlijentIzvjestaj> reportData) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              replaceDiacritics('Izjestaj za klijente (posljednjih 30 dana)'),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildKlijentiPdfTable(reportData),
          pw.SizedBox(height: 20),
          pw.Text(
            replaceDiacritics(
                'Generirano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
    return pdf;
  }

  Future<pw.Document> _generateZaposleniciPdf(
      List<ZaposlenikIzvjestaj> reportData) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              replaceDiacritics(
                  'Izjestaj za zaposlenike (posljednjih 30 dana)'),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildZaposleniciPdfTable(reportData),
          pw.SizedBox(height: 20),
          pw.Text(
            replaceDiacritics(
                'Generirano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildAutoservisPdfTable(List<AutoservisIzvjestaj> reportData) {
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
              replaceDiacritics(e.najpopularnijiProizvodi
                  .map((p) => '${p.naziv} (${p.ukupnaKolicina})')
                  .join(', '))
            ]),
      ],
    );
  }

  pw.Widget _buildKlijentiPdfTable(List<KlijentIzvjestaj> reportData) {
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      data: [
        [
          replaceDiacritics('Klijent'),
          replaceDiacritics('Broj narudzbi'),
          replaceDiacritics('Ukupan iznos'),
          replaceDiacritics('Prosj. vrijednost'),
          replaceDiacritics('Najpopularniji proizvodi')
        ],
        ...reportData.map((e) => [
              replaceDiacritics(e.imePrezime),
              e.brojNarudzbi.toString(),
              '${e.ukupanIznos.toStringAsFixed(2)} KM',
              '${e.prosjecnaVrijednost.toStringAsFixed(2)} KM',
              replaceDiacritics(e.najpopularnijiProizvodi
                  .map((p) => '${p.naziv} (${p.ukupnaKolicina})')
                  .join(', '))
            ]),
      ],
    );
  }

  pw.Widget _buildZaposleniciPdfTable(List<ZaposlenikIzvjestaj> reportData) {
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      data: [
        [
          replaceDiacritics('Zaposlenik'),
          replaceDiacritics('Autoservis'),
          replaceDiacritics('Broj narudzbi'),
          replaceDiacritics('Ukupan iznos'),
          replaceDiacritics('Prosj. vrijednost'),
          replaceDiacritics('Najpopularniji proizvodi')
        ],
        ...reportData.map((e) => [
              replaceDiacritics(e.imePrezime),
              replaceDiacritics(e.autoservis),
              e.brojNarudzbi.toString(),
              '${e.ukupanIznos.toStringAsFixed(2)} KM',
              '${e.prosjecnaVrijednost.toStringAsFixed(2)} KM',
              replaceDiacritics(e.najpopularnijiProizvodi
                  .map((p) => '${p.naziv} (${p.ukupnaKolicina})')
                  .join(', '))
            ]),
      ],
    );
  }

  Future<void> _savePdfLocally(pw.Document pdf, String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null)
        throw Exception("Couldn't access downloads directory");

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
      );

      var filteredData = data.cast<IzvjestajNarudzbi>();

      if (filter['klijentIme'] != null &&
          filter['klijentIme'].toString().isNotEmpty) {
        final searchTerm = filter['klijentIme'].toString().toLowerCase();
        filteredData = filteredData
            .where((e) =>
                e.klijent?.ime?.toLowerCase().contains(searchTerm) ?? false)
            .toList();
      }

      if (filter['zaposlenikIme'] != null &&
          filter['zaposlenikIme'].toString().isNotEmpty) {
        final searchTerm = filter['zaposlenikIme'].toString().toLowerCase();
        filteredData = filteredData
            .where((e) =>
                e.zaposlenik?.ime?.toLowerCase().contains(searchTerm) ?? false)
            .toList();
      }

      if (filter['autoservisNaziv'] != null &&
          filter['autoservisNaziv'].toString().isNotEmpty) {
        final searchTerm = filter['autoservisNaziv'].toString().toLowerCase();
        filteredData = filteredData
            .where((e) =>
                e.autoservis?.naziv?.toLowerCase().contains(searchTerm) ??
                false)
            .toList();
      }

      setState(() {
        izvjestaji = filteredData;
      });
    } catch (e) {
      print('Greška prilikom učitavanja izvještaja: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom učitavanja podataka: $e')),
      );
    }
  }

  void _onFieldChanged(String fieldName, dynamic value) {
    setState(() {
      final stringValue = value?.toString() ?? '';

      if (fieldName == 'klijentIme' && stringValue.isNotEmpty) {
        zaposlenikDisabled = true;
        autoservisDisabled = true;
        _formKey.currentState?.fields['zaposlenikIme']?.didChange(null);
        _formKey.currentState?.fields['autoservisNaziv']?.didChange(null);
      } else if (fieldName == 'zaposlenikIme' && stringValue.isNotEmpty) {
        kupacDisabled = true;
        autoservisDisabled = true;
        _formKey.currentState?.fields['klijentIme']?.didChange(null);
        _formKey.currentState?.fields['autoservisNaziv']?.didChange(null);
      } else if (fieldName == 'autoservisNaziv' && stringValue.isNotEmpty) {
        kupacDisabled = true;
        zaposlenikDisabled = true;
        _formKey.currentState?.fields['klijentIme']?.didChange(null);
        _formKey.currentState?.fields['zaposlenikIme']?.didChange(null);
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
        color: const Color.fromARGB(255, 204, 204, 204),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildFilterForm(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoadingCurrentReport
                          ? null
                          : _downloadCurrentReport,
                      icon: _isLoadingCurrentReport
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text("Download trenutni izvještaj"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(95, 156, 39, 176),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _isLoadingAutoservisReport
                          ? null
                          : _downloadAutoservisReport,
                      icon: _isLoadingAutoservisReport
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text(
                          "Download izvještaj za sve autoservise (30 dana)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(93, 33, 149, 243),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _isLoadingKlijentiReport
                          ? null
                          : _downloadKlijentiReport,
                      icon: _isLoadingKlijentiReport
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text(
                          "Download izvještaj za sve klijente (30 dana)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(94, 76, 175, 79),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _isLoadingZaposleniciReport
                          ? null
                          : _downloadZaposleniciReport,
                      icon: _isLoadingZaposleniciReport
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text(
                          "Download izvještaj za sve zaposlenike (30 dana)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(95, 255, 153, 0),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_ios, size: 16),
                        Text('Povucite za više',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Datum')),
                            DataColumn(label: Text('Klijent')),
                            DataColumn(label: Text('Autoservis')),
                            DataColumn(label: Text('Zaposlenik')),
                            DataColumn(label: Text('Ukupno')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: izvjestaji
                              .map((e) => DataRow(
                                    cells: [
                                      DataCell(Text(e.datumNarudzbe != null
                                          ? _formatDate(e.datumNarudzbe!)
                                          : 'N/A')),
                                      DataCell(Text(e.klijent?.ime ?? 'N/A')),
                                      DataCell(
                                          Text(e.autoservis?.naziv ?? 'N/A')),
                                      DataCell(
                                          Text(e.zaposlenik?.ime ?? 'N/A')),
                                      DataCell(Text(e.ukupnaCijena != null
                                          ? '${e.ukupnaCijena!.toStringAsFixed(2)} KM'
                                          : 'N/A')),
                                      DataCell(Icon(
                                        e.status == true
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: e.status == true
                                            ? Colors.green
                                            : Colors.red,
                                      )),
                                    ],
                                  ))
                              .toList(),
                        ),
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
                        name: 'klijentIme',
                        decoration: const InputDecoration(
                          labelText: 'Klijent (ime)',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !kupacDisabled,
                        onChanged: (value) =>
                            _onFieldChanged('klijentIme', value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'zaposlenikIme',
                        decoration: const InputDecoration(
                          labelText: 'Zaposlenik (ime)',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !zaposlenikDisabled,
                        onChanged: (value) =>
                            _onFieldChanged('zaposlenikIme', value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'autoservisNaziv',
                  decoration: const InputDecoration(
                    labelText: 'Autoservis (naziv)',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !autoservisDisabled,
                  onChanged: (value) =>
                      _onFieldChanged('autoservisNaziv', value),
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

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
