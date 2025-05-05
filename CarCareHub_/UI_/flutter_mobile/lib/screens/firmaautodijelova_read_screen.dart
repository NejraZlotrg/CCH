import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/provider/bpautodijelovi_autoservis_provider.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/screens/bp_autodijelovi_autoservis_screen.dart';
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
  Future initForm() async {
     if (context.read<UserProvider>().role == "Admin" || (context.read<UserProvider>().role == "Firma autodijelova" && context.read<UserProvider>().userId==widget.firmaAutodijelova?.firmaAutodijelovaID)) {
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
    body: SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildFirmaDetails(),
                  ),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.role == "Admin") {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Uredi",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BPAutodijeloviAutoservisScreen(
                                      firmaAutodijelova: widget.firmaAutodijelova,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.storage),
                              label: const Text("Baza autoservisa"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 248, 26, 10),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
    ),
  );
}


Widget _buildFirmaDetails() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Slika firme
      Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 300),
          height: 200,
          margin: const EdgeInsets.only(bottom: 20),
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
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 60, color: Colors.black),
                    SizedBox(height: 10),
                    Text('Nema slike',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ],
                ),
        ),
      ),

      // Naziv firme
      if (widget.firmaAutodijelova?.nazivFirme != null)
        Text(
          widget.firmaAutodijelova!.nazivFirme!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

      const SizedBox(height: 20),

      // Kartice sa podacima
      _buildInfoCard("Grad", widget.firmaAutodijelova?.grad?.nazivGrada),
      _buildInfoCard("Adresa", widget.firmaAutodijelova?.adresa),
      _buildInfoCard("Telefon", widget.firmaAutodijelova?.telefon),
      _buildInfoCard("Email", widget.firmaAutodijelova?.email),
      _buildInfoCard("JIB", widget.firmaAutodijelova?.jib),
      _buildInfoCard("MBS", widget.firmaAutodijelova?.mbs),
    ],
  );
}

Widget _buildInfoCard(String title, String? value) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.symmetric(vertical: 6),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    ),
  );
}
}