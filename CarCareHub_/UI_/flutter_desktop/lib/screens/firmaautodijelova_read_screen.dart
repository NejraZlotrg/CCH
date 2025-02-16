import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/screens/BPAutodijeloviAutoservis_screen.dart';
import 'package:flutter_mobile/screens/firmaautodijelova_details_screen.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FirmaAutodijelovaReadScreen extends StatefulWidget {
   FirmaAutodijelova? firmaAutodijelova;
   FirmaAutodijelovaReadScreen({super.key, this.firmaAutodijelova});

  @override
  State<FirmaAutodijelovaReadScreen> createState() =>
      _FirmaAutodijelovaDetailScreenState();
}

class _FirmaAutodijelovaDetailScreenState
    extends State<FirmaAutodijelovaReadScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  late GradProvider _gradProvider;
  late UlogeProvider _ulogaProvider;
  late BPAutodijeloviAutoservisProvider _bpProvider;
  SearchResult<FirmaAutodijelova>? result;
  List<Grad> grad = [];

  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogaResult;
SearchResult<BPAutodijeloviAutoservis>? bpResult;
List<BPAutodijeloviAutoservis>? temp;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;

    final validator = CreateValidator();

  
  get firmaAutodijelova => null;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivFirme': widget.firmaAutodijelova?.nazivFirme ?? '',
      'adresa': widget.firmaAutodijelova?.adresa ?? '',
      'gradId': widget.firmaAutodijelova?.gradId ?? '',
      'jib': widget.firmaAutodijelova?.jib ?? '',
      'mbs': widget.firmaAutodijelova?.mbs ?? '',
      'telefon': widget.firmaAutodijelova?.telefon ?? '',
      'email': widget.firmaAutodijelova?.email ?? '',
      'username': widget.firmaAutodijelova?.username ?? '',
      'password': widget.firmaAutodijelova?.password ?? '',
      'passwordAgain': widget.firmaAutodijelova?.passwordAgain ?? '',
      'ulogaId': widget.firmaAutodijelova?.ulogaId ?? '',
      
    };

    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogaProvider = context.read<UlogeProvider>();
    _bpProvider = context.read<BPAutodijeloviAutoservisProvider>();


    fetchGrad();
    initForm();
  }

  
  Future<void> fetchGrad() async {
   
      grad = await _gradProvider.getById(widget.firmaAutodijelova?.gradId);
      if (grad.isNotEmpty && grad.first.vidljivo == false) {
      grad = []; // Postavi na praznu listu ako grad nije vidljiv
      _initialValues['gradId']; // Resetuj vrednost za dropdown
  
      if (mounted) {
        setState(() {});
      }
    }
   
  }

  Future<File> _getImageFileFromBase64(String base64String) async {
    final bytes = base64Decode(base64String);
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }


  Future initForm() async {
     if (context.read<UserProvider>().role == "Admin") {
       gradResult = await _gradProvider.getAdmin();
     } else {
       gradResult = await _gradProvider.get();
     }
    if (widget.firmaAutodijelova != null && widget.firmaAutodijelova!.slikaProfila != null) {
      _imageFile =
          await _getImageFileFromBase64(widget.firmaAutodijelova!.slikaProfila!);
    }
    setState(() {
      isLoading = false;
    });
  }



  
  Future<void> _fetchInitialData() async {
  setState(() {
    isLoading = true;
  });

  try {
    SearchResult<FirmaAutodijelova> data;
    if (context.read<UserProvider>().role == "Admin") {
      data = await _firmaAutodijelovaProvider.getAdmin(filter: {'IsAllIncluded': 'true'});
       gradResult = await _gradProvider.getAdmin();

    } else {
      data = await _firmaAutodijelovaProvider.get(filter: {'IsAllIncluded': 'true'});
       gradResult = await _gradProvider.get();

    }

    setState(() {
      result = data;
      // Pronađi i ažuriraj trenutni autoservis
      widget.firmaAutodijelova = data.result.firstWhere(
        (a) => a.firmaAutodijelovaID == widget.firmaAutodijelova?.firmaAutodijelovaID,
        orElse: () => widget.firmaAutodijelova!,
      );
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška pri učitavanju podataka: $e')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
        backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina

    appBar: AppBar(
      title: Text(widget.firmaAutodijelova?.nazivFirme ?? "Detalji firme"),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildFirmaDetails(),
                    ],
                  ),
                ),
              ),
              // Dugme "Uredi" na dnu, vidljivo samo adminima
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.role == "Admin") {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity, // Dugme preko cele širine
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigacija na ekran za uređivanje
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FirmaAutodijelovaDetailScreen(
                                      firmaAutodijelova: widget.firmaAutodijelova!,
                                    ),
                                  ),
                                ).then((_) async {
                                  await _fetchInitialData();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 245, 19, 3),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15), // Veće dugme
                              ),
                              child: const Text(
                                "Uredi",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigacija na BPAutodijeloviAutoservisScreen i prosleđivanje objekta
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BPAutodijeloviAutoservisScreen(
                                      firmaAutodijelova: widget.firmaAutodijelova, // Prosleđivanje objekta
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 248, 26, 10), // Crvena boja dugmeta
                                foregroundColor: Colors.white, // Bijela boja teksta
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                   padding: const EdgeInsets.symmetric(vertical: 15), // Veće dugme
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                
                                children: [
                                  Icon(Icons.storage),
                                  SizedBox(width: 8.0),
                                  Text('Baza autoservisa'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
  );
}



Widget _buildFirmaDetails() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center, // Centriranje slike i podataka
    children: [
      // Prva trećina - Povećana slika firme centrirana
      Expanded(
        flex: 1,
        child: Center(
          child: Container(
            width: 300, // Povećana širina slike
            height: 300, // Povećana visina slike
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _imageFile!,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 70, color: Colors.black), // Veća ikona
                      SizedBox(height: 15),
                      Text('Nema slike',
                          style: TextStyle(color: Colors.black, fontSize: 18)), // Veći tekst
                    ],
                  ),
          ),
        ),
      ),

      // Razmak između slike i podataka
      const SizedBox(width: 40), // Malo veći razmak za bolji balans

      // Druge dvije trećine - Podaci firme centrirani
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.firmaAutodijelova?.nazivFirme != null)
              Text(
                widget.firmaAutodijelova!.nazivFirme!,
                style: const TextStyle(
                    fontSize: 28, // Malo veći naslov
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),

            const SizedBox(height: 25), // Veći razmak ispod naslova

            DataTable(
              columnSpacing: 220, // Veći razmak između stupaca
              horizontalMargin: 10, // Horizontalni margine
              headingRowHeight: 0, // Sakrij zaglavlje
              dataRowHeight: 55, // Veći razmak između redova
              columns: const [
                DataColumn(label: SizedBox()), // Prazan zaglavni red
                DataColumn(label: SizedBox()),
              ],
              rows: [
                _buildDataRow("Grad", widget.firmaAutodijelova?.grad?.nazivGrada),
                _buildDataRow("Adresa", widget.firmaAutodijelova?.adresa),
                _buildDataRow("Telefon", widget.firmaAutodijelova?.telefon),
                _buildDataRow("Email", widget.firmaAutodijelova?.email),
                _buildDataRow("JIB", widget.firmaAutodijelova?.jib),
                _buildDataRow("MBS", widget.firmaAutodijelova?.mbs),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

// Funkcija za kreiranje jednog reda u tabeli s dodatnim razmakom
DataRow _buildDataRow(String label, String? value) {
  return DataRow(
    cells: [
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12), // Još veći razmak unutar ćelije
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12), // Još veći razmak unutar ćelije
          child: Text(value ?? 'Nema podataka', style: const TextStyle(fontSize: 16)),
        ),
      ),
    ],
  );
}


}

