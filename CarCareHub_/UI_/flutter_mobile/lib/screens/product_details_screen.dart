import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  int _quantity = 1; // Default quantity is 1

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
                      // Provjerava postoji li aktivna narudžba
                      int narudzbaId = await _productProvider.getCurrentNarudzbaId();

                      if (narudzbaId == -1) {
                        // Ako nema aktivne narudžbe, kreiraj novu
                        narudzbaId = await _productProvider.createNewNarudzba();
                      }

                      // Pripremi zahtjev za dodavanje stavke u narudžbu
                      var request = {
                        'proizvodId': widget.product?.proizvodId,
                        'kolicina': _quantity,
                        'narudzbaId': narudzbaId, // Dodaj narudzbaId u zahtjev
                      };

                      // Dodaj stavku u narudžbu
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
                  enabled: false, // Disabled to prevent editing
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Naziv"),
                  name: "naziv",
                  initialValue: widget.product?.naziv ?? '',
                  enabled: false, // Disabled to prevent editing
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
                  enabled: false, // Disabled to prevent editing
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
                  enabled: false, // Disabled to prevent editing
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "Opis"),
                  name: "opis",
                  initialValue: widget.product?.opis ?? '',
                  enabled: false, // Disabled to prevent editing
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
