// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GradDetailsScreen extends StatefulWidget {
  Grad? grad;
  GradDetailsScreen({super.key, this.grad});

  @override
  State<GradDetailsScreen> createState() => _GradDetailsScreenState();
}

class _GradDetailsScreenState extends State<GradDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  late GradProvider _gradProvider;
  late DrzaveProvider _drzaveProvider;

  SearchResult<Drzave>? drzavaResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValues = {
      'nazivGrada': widget.grad?.nazivGrada,
      'drzavaId': widget.grad?.drzavaId,
    };

    _drzaveProvider = context.read<DrzaveProvider>();
    _gradProvider = context.read<GradProvider>();
    initForm();
  }

  Future initForm() async {
    drzavaResult = await _drzaveProvider.get();  //////////////////////////////////////////////////////
    print(drzavaResult);

    setState(() {  //////////////////////////////////////////////////////
      isLoading = false;  //////////////////////////////////////////////////////
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(), //////////////////////////////////////////////////////
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.saveAndValidate();

                    var request = Map.from(_formKey.currentState!.value);

                    try {
                      if (widget.grad == null) {
                        await _gradProvider.insert(request);
                      } else {
                        await _gradProvider.update(
                            widget.grad!.gradId!, _formKey.currentState?.value);
                      }
                    } on Exception catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("error"),
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
              ),
            ],
          )
        ],
      ),
      title: widget.grad?.nazivGrada ?? "Detalji drzave",
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
                  decoration: const InputDecoration(labelText: "naziv"),
                  name: "nazivGrada",
                ),
              ),
              Expanded(
                child: FormBuilderDropdown(
                  name: 'drzavaId',
                  decoration: InputDecoration(
                    labelText: 'Drzava',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['drzavaId']?.reset();
                      },
                    ),
                    hintText: 'drzava',
                  ),
                  initialValue: widget.grad?.drzavaId != null
                      ? widget.grad!.drzavaId.toString()
                      : null, // Provjera za null vrijednosti
                  items: drzavaResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.drzavaId.toString(),
                                child: Text(item.nazivDrzave ?? ""),
                              ))
                          .toList() ??
                      [], // Provjera za praznu listu //////////////////////////////////////////////////////
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
