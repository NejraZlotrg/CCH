import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/screens/firmaautodijelova_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class FirmaAutodijelovaScreen extends StatefulWidget {
  const FirmaAutodijelovaScreen({super.key});

  @override
  State<FirmaAutodijelovaScreen> createState() =>
      _FirmaAutodijelovaScreenState();
}
class _FirmaAutodijelovaScreenState extends State<FirmaAutodijelovaScreen> {
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  SearchResult<FirmaAutodijelova>? result;
  final TextEditingController _nazivFirmeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    var data = await _firmaAutodijelovaProvider.get(filter: {'IsAllncluded': 'true'});
    if (mounted) {
      setState(() {
        result = data;
      });
    }
  }

  
void _onSearchPressed() async {
  var filterParams = {
    'IsAllncluded': 'true', // Ovaj parametar ostaje
  };

  // Dodavanje filtera samo ako je naziv unesen
  if (_nazivFirmeController.text.isNotEmpty) {
    filterParams['NazivFirme'] = _nazivFirmeController.text;
  }

  print("Filter Params: $filterParams"); // Debugging log

 try {
                    var data = await _firmaAutodijelovaProvider.get(filter: filterParams);
                    if (mounted) {
                      setState(() {
                        result = data;
                      });
                    }
                  } catch (e) {
                    print("Error fetching filtered data: $e");
                  }

}


  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "FirmaAutodijelova",
      child: Container(
        color: const Color.fromARGB(255, 204, 204, 204), // Dodana siva pozadina
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
    width: MediaQuery.of(context).size.width, // Širina 100% ekrana
    margin: const EdgeInsets.only(top: 20.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField za unos Naziv firme
            TextField(
              controller: _nazivFirmeController,
              decoration: const InputDecoration(
                labelText: 'Naziv firme',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10), // Razmak između TextField i dugmeta
            
            // Dugme za Pretragu
            ElevatedButton(
              onPressed: _onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8.0),
                  Text('Pretraga'),
                ],
              ),
            ),
            const SizedBox(height: 10), // Razmak između dugmadi
            
            // Dugme za Dodavanje (ako je admin)
            if (context.read<UserProvider>().role == "Admin")
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const FirmaAutodijelovaDetailScreen(firmaAutodijelova: null),
                    ),
                  );
                  await _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8.0),
                    Text('Dodaj'),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}Widget _buildDataListView() {
   return Expanded( // Koristimo Expanded kako bi popunili preostali prostor
      child: SingleChildScrollView( // Omogućavamo skrolovanje za ceo sadržaj
        child: Container(
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(top: 20.0),
    child: Column(
      children: result?.result
              .map(
                (FirmaAutodijelova e) => GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FirmaAutodijelovaDetailScreen(
                          firmaAutodijelova: e,
                        ),
                      ),
                    );
                    // Osvježi podatke nakon povratka s detaljnog ekrana
                    await _loadData();
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    elevation: 4.0, // Vizualni efekat sjene
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Slika
                          if (e.slikaProfila != null)
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: imageFromBase64String(e.slikaProfila!),
                            )
                          else
                            const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(child: Text("Nema slike")),
                            ),
                          const SizedBox(width: 10),
                          // Naziv firme, adresa i grad
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Naziv firme (boldirano)
                                Text(
                                  e.nazivFirme ?? "Naziv firme nije dostupan",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Adresa (normalno formatirano)
                                Text(
                                  e.adresa ?? "Adresa nije dostupna",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Grad (normalno formatirano)
                                Text(
                                  e.grad?.nazivGrada ?? "Grad nije dostupan",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList() ?? [],
    ),
  )));
}


}