// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/drzave.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
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

final validator = CreateValidator();
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
     if (context.read<UserProvider>().role == "Admin") {
       drzavaResult = await _drzaveProvider.getAdmin();
     } else {
       drzavaResult = await _drzaveProvider.get(); //////////////////////////////////////////////////////
     }
    print(drzavaResult);

    setState(() {  //////////////////////////////////////////////////////
      isLoading = false;  //////////////////////////////////////////////////////
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
    appBar: AppBar(
      title: Text(widget.grad?.nazivGrada ?? "Detalji grada"),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildForm(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                                                  Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Potvrda brisanja
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Potvrda brisanja"),
                                    content: const Text(
                                        "Da li ste sigurni da želite izbrisati ovaj grad?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Otkaži"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Izbriši"),
                                      ),
                                    ],
                                  ),
                                );

                                // Ako korisnik potvrdi brisanje
                                if (confirmDelete == true) {
                                  try {
                                    await _gradProvider.delete(
                                        widget.grad!.gradId!);
                                    Navigator.pop(context); // Vrati se na prethodni ekran
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Grad uspješno izbrisan."),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Nemoguće obrisati jer postoje povezani podaci."),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red[700], // Crvena boja za brisanje
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Izbriši"),
                            ),
                          ),
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
                    _formKey.currentState?.saveAndValidate();

                    var request = Map.from(_formKey.currentState!.value);

                    try {
                      if (widget.grad == null) {
                        await _gradProvider.insert(request);
                      } else {
                        await _gradProvider.update(
                            widget.grad!.gradId!, _formKey.currentState?.value);
                      }
                        Navigator.pop(context);
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
            
          )
        ],
      ),
            ),)
    );
  }

    FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValues,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ..._buildFormFields(),
        ],
      ),
    );
  }
List<Widget> _buildFormFields() {
    return [
      Row(
        children: [
          Expanded(
              child: FormBuilderTextField(
                  decoration: const InputDecoration(
                    labelText: "Naziv grada",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white, // Bela pozadina
                    filled: true, // Da pozadina bude ispunjena
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: validator.required,
                  name: "nazivGrada"))
        ],
      ),
        const SizedBox(height: 20),
      Row(
        children: [
         Expanded(
  child: FormBuilderDropdown(
    name: 'drzavaId',
    validator: validator.required,
    decoration: const InputDecoration(
      labelText: 'Država',
      border: OutlineInputBorder(),
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      hintText: 'Izaberite državu',
    ),
    initialValue: widget.grad?.drzavaId?.toString(),
    items: drzavaResult?.result
            .map((item) => DropdownMenuItem(
                  alignment: AlignmentDirectional.center,
                  value: item.drzavaId.toString(),
                  child: Text(
                    item.nazivDrzave ?? "",
                    style: TextStyle(
                      color: item.vidljivo == false ? Colors.red : Colors.black,
                    ),
                  ),
                ))
            .toList() ??
        [],
  ),
)

        ],
      ),
            const SizedBox(height: 20),

    ];
  }
}
