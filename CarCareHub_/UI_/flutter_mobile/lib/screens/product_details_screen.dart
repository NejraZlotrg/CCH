import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  ProductDetailScreen({super.key, this.product});

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

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    initForm();
  }

  Future<void> initForm() async {
    setState(() {
      isLoading = false;
    });
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
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      int narudzbaId = await _productProvider.getCurrentNarudzbaId();
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
                            '${widget.product?.naziv ?? "Proizvod"} je dodan u košaricu! Količina: $_quantity'),
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
                  child: const Text("Dodaj u košaricu"),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.saveAndValidate();

                  var request = Map.from(_formKey.currentState!.value);
                  
                  if (_imageFile != null) {
                    request['slika'] = base64Encode(await _imageFile!.readAsBytes());
                    request['slikaThumb'] = base64Encode(await _imageFile!.readAsBytes());
                  }

                  try {
                    if (widget.product == null) {
                      await _productProvider.insert(request);
                    } else {
                      await _productProvider.update(
                          widget.product!.proizvodId!, request);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Proizvod uspješno dodan."),
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
                          )
                        ],
                      ),
                    );
                  }
                },
                child: const Text("Spasi"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Šifra"),
                  name: "sifra",
                  initialValue: widget.product?.sifra ?? '',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Naziv"),
                  name: "naziv",
                  initialValue: widget.product?.naziv ?? '',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Originalni broj"),
                  name: "originalniBroj",
                  initialValue: widget.product?.originalniBroj ?? '',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Model"),
                  name: "model",
                  initialValue: widget.product?.model ?? '',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Opis"),
                  name: "opis",
                  initialValue: widget.product?.opis ?? '',
                ),
              ),
                Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Cijena"),
                  name: "cijena",
                  initialValue: widget.product?.cijena.toString(),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Odaberi Sliku"),
              ),
              const SizedBox(width: 10),
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                    )
                  : const Text("No image selected"),
            ],
          ),
        ],
      ),
    );
  }
}
