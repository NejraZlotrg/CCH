import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/autoservis_usluge.dart';
import 'package:flutter_mobile/models/usluge.dart'; // Uvezi model Usluga
import 'package:flutter_mobile/provider/autoservis_usluge_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AutoservisUslugeDetailsScreen extends StatefulWidget {
  final AutoservisUsluge? autoservisUsluge;

  AutoservisUslugeDetailsScreen({super.key, this.autoservisUsluge});

  @override
  State<AutoservisUslugeDetailsScreen> createState() => AutoservisUslugeDetailsScreenState();
}

class AutoservisUslugeDetailsScreenState extends State<AutoservisUslugeDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late AutoservisUslugeProvider _autoservisUslugeProvider;
  List<String> nazivUslugeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _autoservisUslugeProvider = context.read<AutoservisUslugeProvider>();
    initForm();
  }

  Future<void> initForm() async {
    if (widget.autoservisUsluge != null) {
      final autoservisId = widget.autoservisUsluge!.autoservisId;
      if (autoservisId != null) {
        // Učitaj usluge za izabrani autoservis
        var response = await _autoservisUslugeProvider.getByAutoservisId(autoservisId);
        var jsonList = response as List; // Pretpostavljam da je odgovor lista JSON objekata

        // Mape u AutoservisUsluge
        List<AutoservisUsluge> autoservisUslugeList = jsonList.map((json) => AutoservisUsluge.fromJson(json)).toList();

        // Učitaj samo naziv usluga
        nazivUslugeList = autoservisUslugeList
            .map((autoservisUsluga) => autoservisUsluga.usluge?.nazivUsluge ?? "")
            .where((naziv) => naziv.isNotEmpty) // Filtriraj prazne nazive
            .toList();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.autoservisUsluge?.autoservis?.naziv ?? "Detalji autoservisa",
      child: SingleChildScrollView(
        child: Column(
          children: [
            isLoading ? CircularProgressIndicator() : _buildForm(),
            _buildUslugeTable(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'uslugeId': widget.autoservisUsluge?.uslugeId?.toString(),
        'autoservisId': widget.autoservisUsluge?.autoservisId?.toString(),
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'uslugeId',
                  decoration: InputDecoration(
                    labelText: 'Usluge',
                    hintText: 'Izaberi uslugu',
                  ),
                  items: nazivUslugeList.isNotEmpty
                      ? nazivUslugeList.map((naziv) => DropdownMenuItem<String>(
                            value: naziv,
                            child: Text(naziv),
                          )).toList()
                      : [DropdownMenuItem(value: null, child: Text("Nema dostupnih usluga"))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUslugeTable() {
    return nazivUslugeList.isEmpty
        ? const Text("Nema dostupnih usluga.")
        : DataTable(
            columns: const [
              DataColumn(label: Text('Naziv usluge')),
            ],
            rows: nazivUslugeList
                .map((naziv) => DataRow(cells: [
                      DataCell(Text(naziv)),
                    ]))
                .toList(),
          );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            var request = Map.from(_formKey.currentState!.value);

            try {
              if (widget.autoservisUsluge == null) {
                await _autoservisUslugeProvider.insert(request);
              } else {
                await _autoservisUslugeProvider.update(
                    widget.autoservisUsluge!.autoservisUslugeId, request);
              }
              Navigator.pop(context);
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
                    )
                  ],
                ),
              );
            }
          }
        },
        child: const Text("Spasi"),
      ),
    );
  }
}
