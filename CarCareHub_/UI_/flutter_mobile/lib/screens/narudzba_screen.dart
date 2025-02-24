import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/narudzba.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class NarudzbaScreen extends StatefulWidget {
  const NarudzbaScreen({super.key});

  @override
  State<NarudzbaScreen> createState() => _NarudzbaScreenState();
}

class _NarudzbaScreenState extends State<NarudzbaScreen> {
  late NarudzbaProvider _narudzbaProvider;
  SearchResult<Narudzba>? result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    loadData();
  }

  Future<void> loadData() async {
    var data = await _narudzbaProvider.get();
    setState(() {
      result = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Narudzbe",
      child: Column(
        children: [
          Expanded(
            child: _buildDataListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    if (result == null || result!.result.isEmpty) {
      return const Center(
        child: Text(
          "Nema narudžbi",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: result!.result.length,
      itemBuilder: (context, index) {
        final narudzba = result!.result[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Narudzba ID', narudzba.narudzbaId.toString()),
                _buildRow('Datum narudzbe', narudzba.datumNarudzbe.toString()),
                _buildRow('Datum isporuke', narudzba.datumIsporuke.toString()),
                _buildRow('Zavrsena narudzba', narudzba.zavrsenaNarudzba.toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}