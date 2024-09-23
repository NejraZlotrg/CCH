// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/kategorija.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/vozilo.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/vozilo.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProductDetailScreen extends StatefulWidget {
  Product? product;
  ProductDetailScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late KategorijaProvider _kategorijaProvider;
  late VoziloProvider _voziloProvider;
  late ProductProvider _productProvider;

  SearchResult<Kategorija>? kategorijaResult;
  SearchResult<Vozilo>? voziloResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'sifra': widget.product?.sifra,
      'naziv': widget.product?.naziv,
      'cijena': widget.product?.cijena,
      'popust': widget.product?.popust,
      'originalniBroj': widget.product?.originalniBroj,
      'cijenaSaPopustom': widget.product?.cijenaSaPopustom,
      'model': widget.product?.model,
      'opis': widget.product?.opis,
      'voziloId': widget.product?.voziloId?.toString(),
      'kategorijaId': widget.product?.kategorijaId?.toString(),
    };

    _kategorijaProvider = context.read<KategorijaProvider>();
    _voziloProvider = context.read<VoziloProvider>();
    _productProvider = context.read<ProductProvider>();

    initForm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _kategorijaProvider = context.read<KategorijaProvider>();
    _voziloProvider = context.read<VoziloProvider>();
  }

  Future initForm() async {
    kategorijaResult = await _kategorijaProvider.get();
    print(kategorijaResult);

    voziloResult = await _voziloProvider.get();
    print(voziloResult);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState?.saveAndValidate();

                      print(_formKey.currentState?.value);
                      print(_formKey.currentState?.value['naziv']);

                      try {
                        if (widget.product == null) {
                          await _productProvider.insert(_formKey.currentState?.value);
                        } else {
                          await _productProvider.update(
                              widget.product!.proizvodId!, _formKey.currentState?.value);
                        }
                      } on Exception catch (e) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text("error"),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK"))
                                  ],
                                ));
                      }
                    },
                    child: Text("Spasi")),
              ),
            ],
          )
        ],
      ),
      title: widget.product?.naziv ?? "Detalji Proizvoda",
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValues,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "sifra"),
                  name: "sifra",
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "naziv"),
                  name: "naziv",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "originalniBroj"),
                  name: "originalniBroj",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "model"),
                  name: "model",
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FormBuilderTextField(
                  decoration: const InputDecoration(labelText: "opis"),
                  name: "opis",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown(
                  name: 'voziloId',
                  decoration: InputDecoration(
                    labelText: 'Vozilo',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['voziloId']?.reset();
                      },
                    ),
                    hintText: 'vozilo',
                  ),
                  initialValue: widget.product?.voziloId != null
                      ? widget.product!.voziloId.toString()
                      : null, // Provjera za null vrijednosti
                  items: voziloResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.voziloId.toString(),
                                child: Text(item.markaVozila ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown(
                  name: 'kategorijaId',
                  decoration: InputDecoration(
                    labelText: 'Kategorija',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['kategorijaId']?.reset();
                      },
                    ),
                    hintText: 'kategorija',
                  ),
                  initialValue: widget.product?.kategorijaId != null
                      ? widget.product!.kategorijaId.toString()
                      : null, // Provjera za null vrijednosti
                  items: kategorijaResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.kategorijaId.toString(),
                                child: Text(item.nazivKategorije ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
