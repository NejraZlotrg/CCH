import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late ProductProvider _productProvider;
  bool isLoading = true;
  int _quantity = 1;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late VoziloProvider _voziloProvider;
  SearchResult<Vozilo>? voziloResult;
  late KategorijaProvider _kategorijaProvider;
  SearchResult<Kategorija>? kategorijaResult;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  SearchResult<FirmaAutodijelova>? firmaAutodijelovaResult;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();

    initForm();
  }

 Future<void> initForm() async {
  voziloResult = await _voziloProvider.get();
  kategorijaResult = await _kategorijaProvider.get();
  firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get();

  // Check if product exists and slika is not null
  if (widget.product != null && widget.product!.slika != null) {
    // Use the null assertion operator (!) to treat slika as non-null
    _imageFile = await _getImageFileFromBase64(widget.product!.slika!);
  }

  setState(() {
    isLoading = false;
  });
}

// Function to convert base64 image to File
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

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.product?.naziv ?? "Detalji Proizvoda",
      child: SingleChildScrollView(
        child: Row(
          // Koristi Row za dve kolone
          children: [
            Expanded(
              flex: 2, // Proporcionalna širina za levu kolonu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prikaz slike
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      alignment: Alignment.topLeft, // Poravnanje slike
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: 250, // Smanjena širina slike
                              height: 250, // Smanjena visina slike
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 250, // Smanjena širina praznog prostora
                              height: 250,
                              color: Colors.grey[300],
                              child: const Center(child: Text("Odaberi sliku")),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Prikaz opisa
                  FormBuilderTextField(
                    decoration: const InputDecoration(labelText: "Opis"),
                    name: "opis",
                    initialValue: widget.product?.opis ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16), // Razmak između kolona
            Expanded(
              flex: 3, // Proporcionalna širina za desnu kolonu
              child: isLoading ? Container() : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Poravnanje elemenata levo
        children: [
          FormBuilderTextField(
            decoration: const InputDecoration(labelText: "Šifra"),
            name: "sifra",
            initialValue: widget.product?.sifra ?? '',
          ),
          const SizedBox(height: 10), // Razmak između polja
          FormBuilderTextField(
            decoration: const InputDecoration(labelText: "Naziv"),
            name: "naziv",
            initialValue: widget.product?.naziv ?? '',
          ),
          const SizedBox(height: 10), // Razmak između polja
          FormBuilderTextField(
            decoration: const InputDecoration(labelText: "Originalni broj"),
            name: "originalniBroj",
            initialValue: widget.product?.originalniBroj ?? '',
          ),
          const SizedBox(height: 10), // Razmak između polja
          FormBuilderTextField(
            decoration: const InputDecoration(labelText: "Model"),
            name: "model",
            initialValue: widget.product?.model ?? '',
          ),
          const SizedBox(height: 10), // Razmak između polja
          FormBuilderDropdown(
            name: 'kategorijaId',
            decoration: const InputDecoration(
              labelText: 'Kategorija',
              hintText: 'kategorija',
            ),
            initialValue: widget.product?.kategorijaId?.toString(),
            items: kategorijaResult?.result.map((item) {
                  return DropdownMenuItem(
                    value: item.kategorijaId.toString(),
                    child: Text(item.nazivKategorije ?? ""),
                  );
                }).toList() ??
                [],
          ),
          const SizedBox(height: 10), // Razmak između polja
          FormBuilderDropdown(
            name: 'firmaAutodijelovaID',
            decoration: const InputDecoration(
              labelText: 'FirmaAutodijelova',
              hintText: 'firmaAutodijelova',
            ),
            initialValue: widget.product?.firmaAutodijelovaID?.toString(),
            items: firmaAutodijelovaResult?.result.map((item) {
                  return DropdownMenuItem(
                    value: item.firmaAutodijelovaID.toString(),
                    child: Text(item.nazivFirme ?? ""),
                  );
                }).toList() ??
                [],
          ),
          const SizedBox(height: 10),
          FormBuilderDropdown(
            name: 'voziloId',
            decoration: const InputDecoration(
              labelText: 'Vozilo',
              hintText: 'vozilo',
            ),
            initialValue: widget.product?.voziloId?.toString(),
            items: voziloResult?.result.map((item) {
                  return DropdownMenuItem(
                    value: item.voziloId.toString(),
                    child: Text(item.markaVozila ?? ""),
                  );
                }).toList() ??
                [],
          ),
          const SizedBox(height: 10), // Razmak između polja
          FormBuilderTextField(
            decoration: const InputDecoration(labelText: "Cijena"),
            name: "cijena",
            initialValue: widget.product?.cijena.toString(),
          ),
          const SizedBox(height: 10), // Razmak između polja
          ElevatedButton(
            onPressed: () async {
              _formKey.currentState?.saveAndValidate();
              var request = Map.from(_formKey.currentState!.value);
                  request['opis'] = _formKey.currentState!.fields['opis']?.value; // Provjeri da li je ovo ispravno


              if (_imageFile != null) {
                request['slika'] =
                    base64Encode(await _imageFile!.readAsBytes());
                request['slikaThumb'] =
                    base64Encode(await _imageFile!.readAsBytes());
              }

              try {
                if (widget.product == null) {
                  await _productProvider.insert(request);
                } else {
                  await _productProvider.update(
                    widget.product!.proizvodId!,
                    request,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Proizvod uspješno dodan."),
                ));
              } on Exception catch (e) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("Greška"),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text("Spasi"),
          ),
          const SizedBox(height: 10), // Razmak između dugmadi
          // Quantity selector
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (_quantity > 1) _quantity--;
                  });
                },
              ),
              Text('$_quantity', style: const TextStyle(fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    int narudzbaId =
                        await _productProvider.getCurrentNarudzbaId();
                    if (narudzbaId == -1) {
                      narudzbaId = await _productProvider.createNewNarudzba();
                    }

                    var request = {
                      'proizvodId': widget.product?.proizvodId,
                      'kolicina': _quantity,
                      'narudzbaId': narudzbaId,
                    };

                    await _productProvider.addNarudzbaStavka(request);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${widget.product?.naziv ?? "Proizvod"} je dodan u košaricu.'),
                    ));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Greška: ${e.toString()}"),
                    ));
                  }
                },
                child: const Text("Dodaj u korpu"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
