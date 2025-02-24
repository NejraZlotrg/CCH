import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/model.dart';
import 'package:flutter_mobile/models/proizvodjac.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/proizvodjac_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
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
  late KorpaProvider _korpaProvider;

  bool isLoading = true;
  int _quantity = 1;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late ModelProvider _modelProvider;
  SearchResult<Model>? modelResult;
  late KategorijaProvider _kategorijaProvider;
  SearchResult<Kategorija>? kategorijaResult;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;
  SearchResult<FirmaAutodijelova>? firmaAutodijelovaResult;
  late ProizvodjacProvider _proizvodjacProvider;
  SearchResult<Proizvodjac>? proizvodjacResult;

      final validator = CreateValidator();


  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _korpaProvider = context.read<KorpaProvider>();

    _modelProvider = context.read<ModelProvider>();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    _proizvodjacProvider = context.read<ProizvodjacProvider>();

    initForm();
  }

  Future<void> initForm() async {
    
  if (context.read<UserProvider>().role == "Admin"){
    modelResult = await _modelProvider.getAdmin();
    kategorijaResult = await _kategorijaProvider.getAdmin();
    firmaAutodijelovaResult = await _firmaAutodijelovaProvider.getAdmin();
    proizvodjacResult = await _proizvodjacProvider.getAdmin();
 }
 else {
    modelResult = await _modelProvider.get();
    kategorijaResult = await _kategorijaProvider.get();
    firmaAutodijelovaResult = await _firmaAutodijelovaProvider.get();
    proizvodjacResult = await _proizvodjacProvider.get();
 }
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
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
      appBar: AppBar(
        title: Text(widget.product?.naziv ?? "Detalji proizvoda"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildForm(), // Call the form builder function
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          // Dugme za spašavanje
                          ElevatedButton(
                            onPressed: () async {
                                  if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo popunite obavezna polja."),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Zaustavi obradu ako validacija nije prošla
    }
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                var request =
                                    Map.from(_formKey.currentState!.value);

                                // Dodaj sliku u request
                                if (_imageFile != null) {
                                  final imageBytes =
                                      await _imageFile!.readAsBytes();
                                  request['slika'] = base64Encode(imageBytes);
                                  request['slikaThumb'] =
                                      base64Encode(imageBytes);
                                } else {
  // Ako nije poslana, učitaj iz assets-a
  const assetImagePath = 'assets/images/proizvod_prazna_slika.jpg';
  var imageFile = await rootBundle.load(assetImagePath);
  final imageBytes = imageFile.buffer.asUint8List();
  request['slika'] = base64Encode(imageBytes);
}
  request['vidljivo'] = true;


                                try {
                                  if (widget.product == null) {
                                    await _productProvider.insert(request);
                                  } else {
                                    await _productProvider.update(
                                      widget.product!.proizvodId!,
                                      request,
                                    );
                                  }
                                  Navigator.pop(context);
                                } on Exception catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text("Greška"),
                                      content: Text(e.toString()),
                                      actions: const [
                                      
                                        
                                      ],
                                    ),
                                  );
                                }
                              }


                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Spasi"),
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

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align elements to the left
        children: [
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 250,
                height: 250,
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
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ): const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 60, color: Colors.black),
              SizedBox(height: 10),
              Text('Odaberite sliku',
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._buildFormFields(), // Adding the form fields here
          const SizedBox(height: 10),
 
          // Quantity selector
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (_quantity >= 1) _quantity--;
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
              // Add to cart button
ElevatedButton(
  onPressed: () async {
    if (widget.product?.proizvodId != null) {
      final int productId = widget.product!.proizvodId!;

      // Formiraj zahtjev
      var request = Map.from(_formKey.currentState!.value);
      request['proizvodId'] = productId;
      request['kolicina'] = _quantity;

      try {
        await _korpaProvider.insert(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Proizvod dodan u korpu.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Proizvod nije validan.")),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    textStyle: const TextStyle(fontSize: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text("Dodaj u korpu"),
),

            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      FormBuilderTextField(
        decoration: const InputDecoration(
          labelText: "Šifra",
          border: OutlineInputBorder(),
          fillColor: Colors.white, // Bela pozadina
          filled: true, // Da pozadina bude ispunjena
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        name: "sifra",
        validator: validator.required,
        initialValue: widget.product?.sifra ?? '',
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        decoration: const InputDecoration(
          labelText: "Naziv", border: OutlineInputBorder(),
          fillColor: Colors.white, // Bela pozadina
          filled: true, // Da pozadina bude ispunjena
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        name: "naziv",
        validator: validator.required,
        initialValue: widget.product?.naziv ?? '',
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        decoration: const InputDecoration(
            labelText: "Originalni broj",
            border: OutlineInputBorder(),
            fillColor: Colors.white, // Bela pozadina
            filled: true, // Da pozadina bude ispunjena
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
        name: "originalniBroj",
        validator: validator.required,
        initialValue: widget.product?.originalniBroj ?? '',
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        decoration: const InputDecoration(
            labelText: "ModelProizvoda",
            border: OutlineInputBorder(),
            fillColor: Colors.white, // Bela pozadina
            filled: true, // Da pozadina bude ispunjena
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
        name: "modelProizvoda",
        validator: validator.required,
        initialValue: widget.product?.modelProizvoda ?? '',
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child:
         FormBuilderDropdown(
  name: 'kategorijaId',
  validator: validator.required,
  decoration: const InputDecoration(
    labelText: 'Kategorija',
    border: OutlineInputBorder(),
    fillColor: Colors.white, // Bela pozadina
    filled: true, // Da pozadina bude ispunjena
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    hintText: 'Kategorija',
  ),
  initialValue: widget.product?.kategorijaId?.toString(),
  items: kategorijaResult?.result.map((item) {
        return DropdownMenuItem(
          value: item.kategorijaId.toString(),
          child: Text(
            item.nazivKategorije ?? "",
            style: TextStyle(
              color: item.vidljivo == false ? Colors.red : Colors.black,
            ),
          ),
        );
      }).toList() ?? [],
)

          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child:
          FormBuilderDropdown(
  name: 'proizvodjacId',
  validator: validator.required,
  decoration: const InputDecoration(
    labelText: 'Proizvođač',
    border: OutlineInputBorder(),
    fillColor: Colors.white, // Bela pozadina
    filled: true, // Da pozadina bude ispunjena
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    hintText: 'Proizvođač',
  ),
  initialValue: widget.product?.proizvodjacId?.toString(),
  items: proizvodjacResult?.result.map((item) {
        return DropdownMenuItem(
          value: item.proizvodjacId.toString(),
          child: Text(
            item.nazivProizvodjaca ?? "",
            style: TextStyle(
              color: item.vidljivo == false ? Colors.red : Colors.black,
            ),
          ),
        );
      }).toList() ?? [],
)

          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child:
         FormBuilderDropdown(
  name: 'firmaAutodijelovaID',
  validator: validator.required,
  decoration: const InputDecoration(
    labelText: 'Firma Auto Dijelova',
    border: OutlineInputBorder(),
    fillColor: Colors.white, // Bela pozadina
    filled: true, // Da pozadina bude ispunjenae
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    hintText: 'Firma Auto Dijelova',
  ),
  initialValue: widget.product?.firmaAutodijelovaID?.toString(),
  items: firmaAutodijelovaResult?.result.map((item) {
        return DropdownMenuItem(
          value: item.firmaAutodijelovaID.toString(),
          child: Text(
            item.nazivFirme ?? "",
            style: TextStyle(
              color: item.vidljivo == false ? Colors.red : Colors.black,
            ),
          ),
        );
      }).toList() ?? [],
)

          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: FormBuilderDropdown(
  name: 'modelId',
  validator: validator.required,
  decoration: const InputDecoration(
    labelText: 'Model',
    border: OutlineInputBorder(),
    fillColor: Colors.white, // Bela pozadina
    filled: true, // Da pozadina bude ispunjena
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    hintText: 'Odaberite Model',
  ),
  initialValue: widget.product?.model?.modelId.toString(),
  items: modelResult?.result.map((item) {
        return DropdownMenuItem(
          value: item.modelId.toString(),
          child: Text(
            item.nazivModela ?? "",
            style: TextStyle(
              color: item.vidljivo == false ? Colors.red : Colors.black,
            ),
          ),
        );
      }).toList() ?? [],
)

          ),
        ],
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        decoration: const InputDecoration(
            labelText: "Cijena",
            border: OutlineInputBorder(),
            fillColor: Colors.white, // Bela pozadina
            filled: true, // Da pozadina bude ispunjena
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
        name: "cijena",
        validator: validator.required,
        initialValue: widget.product?.cijena.toString(),
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        decoration: const InputDecoration(
            labelText: "Popust",
            border: OutlineInputBorder(),
            fillColor: Colors.white, // Bela pozadina
            filled: true, // Da pozadina bude ispunjena
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
        name: "popust",
        initialValue: widget.product?.popust.toString(),
      ),
      const SizedBox(height: 10),
      FormBuilderTextField(
        decoration: const InputDecoration(
            labelText: "Opis",
            border: OutlineInputBorder(),
            fillColor: Colors.white, // Bela pozadina
            filled: true, // Da pozadina bude ispunjena
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
        name: "opis",

        initialValue: widget.product?.opis ?? '',
      ),
    ];
  }
}
