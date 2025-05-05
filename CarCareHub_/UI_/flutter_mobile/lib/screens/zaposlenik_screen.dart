import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/screens/zaposlenik_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ZaposlenikScreen extends StatefulWidget {
  const ZaposlenikScreen({super.key});

  @override
  State<ZaposlenikScreen> createState() => _ZaposlenikScreenState();
}

class _ZaposlenikScreenState extends State<ZaposlenikScreen> {
  late ZaposlenikProvider _zaposlenikProvider;
  SearchResult<Zaposlenik>? result;
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    SearchResult<Zaposlenik> data;
    if (context.read<UserProvider>().role == "Admin") {
      data =
          await _zaposlenikProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
    } else {
      data = await _zaposlenikProvider.get(filter: {'IsAllIncluded': 'true'});
    }

    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Zaposlenici",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204),
        child: Column(
          children: [
            _buildSearch(),
            _buildDataListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 20.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
          side: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Ime',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: _imeController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Prezime",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: _prezimeController,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        var filterParams = {
                          'IsAllIncluded': 'true',
                        };

                        if (_imeController.text.isNotEmpty) {
                          filterParams['ime'] = _imeController.text;
                        }
                        if (_prezimeController.text.isNotEmpty) {
                          filterParams['prezime'] = _prezimeController.text;
                        }

                        SearchResult<Zaposlenik> data;
                        if (context.read<UserProvider>().role == "Admin") {
                          data = await _zaposlenikProvider.getAdmin(
                              filter: filterParams);
                        } else {
                          data = await _zaposlenikProvider.get(
                              filter: filterParams);
                        }

                        setState(() {
                          result = data;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 8.0),
                          Text('Pretraga'),
                        ],
                      ),
                    ),
                  ),
                  if (context.read<UserProvider>().role == "Admin") ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ZaposlenikDetailsScreen(
                                      zaposlenik: null),
                            ),
                          );
                          await _loadData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8.0),
                            Text('Dodaj'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
        child: SingleChildScrollView(
            child: Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 20.0),
      child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result?.result.length ?? 0,
            itemBuilder: (context, index) {
              final zaposlenik = result!.result[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ZaposlenikDetailsScreen(zaposlenik: zaposlenik),
                    ),
                  );
                  await _loadData();
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${zaposlenik.ime ?? "-"} ${zaposlenik.prezime ?? "-"}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Grad: ${zaposlenik.grad?.nazivGrada ?? "-"}",
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    )));
  }
}
