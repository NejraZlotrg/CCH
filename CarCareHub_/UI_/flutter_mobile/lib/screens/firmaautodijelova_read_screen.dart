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

// ignore: must_be_immutable
class FirmaAutodijelovaReadScreen extends StatefulWidget {
   FirmaAutodijelova? firmaAutodijelova;
   FirmaAutodijelovaReadScreen({super.key, this.firmaAutodijelova});

  @override
  State<FirmaAutodijelovaReadScreen> createState() =>
      _FirmaAutodijelovaDetailScreenState();
}

class _FirmaAutodijelovaDetailScreenState
    extends State<FirmaAutodijelovaReadScreen> {
  Map<String, dynamic> _initialValues = {};
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  late GradProvider _gradProvider;
  SearchResult<FirmaAutodijelova>? result;
  List<Grad> grad = [];

  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogaResult;
SearchResult<BPAutodijeloviAutoservis>? bpResult;
List<BPAutodijeloviAutoservis>? temp;
  File? _imageFile;

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


    fetchGrad();
    initForm();
  }

  
  Future<void> fetchGrad() async {
   
      grad = await _gradProvider.getById(widget.firmaAutodijelova!.gradId ?? 0);
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
       gradResult = await _gradProvider.getAdmin(filter: {'IsAllIncluded': 'true'});

    } else {
      data = await _firmaAutodijelovaProvider.get(filter: {'IsAllIncluded': 'true'});
       gradResult = await _gradProvider.get(filter: {'IsAllIncluded': 'true'});

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
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15), // Zaobljeni uglovi
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Red za sliku i naziv
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slika u gornjem levom uglu
            if (_imageFile != null)
              Container(
                width: 100, // Širina slike
                height: 100, // Visina slike
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 30, color: Colors.black),
                    SizedBox(height: 5),
                    Text('Nema slike', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

            const SizedBox(width: 20), // Razmak između slike i naziva

            // Naziv u gornjem desnom uglu
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  widget.firmaAutodijelova?.nazivFirme ?? "Nema naziva",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20), // Razmak ispod slike i naziva

        // Lokacija (adresa + grad) s ikonicom
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 20), // Ikona lokacije
            const SizedBox(width: 8), // Razmak između ikone i teksta
            Text(
              "${widget.firmaAutodijelova?.adresa ?? 'Nema podataka'}, ${widget.firmaAutodijelova?.grad?.nazivGrada ?? ''}",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),

        const SizedBox(height: 20), // Razmak ispod lokacije

        // Ostali podaci (telefon, email, JIB, MBS)
        _buildInfoRow("Telefon", widget.firmaAutodijelova?.telefon),
        const SizedBox(height: 12),
        _buildInfoRow("Email", widget.firmaAutodijelova?.email),
        const SizedBox(height: 12),
        _buildInfoRow("JIB", widget.firmaAutodijelova?.jib),
        const SizedBox(height: 12),
        _buildInfoRow("MBS", widget.firmaAutodijelova?.mbs),
      ],
    ),
  );
}

// Funkcija za kreiranje jednog reda s podacima
Widget _buildInfoRow(String label, String? value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$label: ",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      Expanded(
        child: Text(
          value ?? 'Nema podataka',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    ],
  );
}

}

