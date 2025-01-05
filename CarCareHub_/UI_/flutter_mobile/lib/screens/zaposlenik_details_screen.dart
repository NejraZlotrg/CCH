import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/uloge.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/firmaautodijelova.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ZaposlenikDetailsScreen extends StatefulWidget {
  final Zaposlenik? zaposlenik;
  ZaposlenikDetailsScreen({Key? key, this.zaposlenik}) : super(key: key);

  @override
  State<ZaposlenikDetailsScreen> createState() => _ZaposlenikDetailsScreenState();
}

class _ZaposlenikDetailsScreenState extends State<ZaposlenikDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late ZaposlenikProvider _zaposlenikProvider;
  late GradProvider _gradProvider;
  late UlogeProvider _ulogeProvider;
  late AutoservisProvider _autoservisProvider;
  late FirmaAutodijelovaProvider _firmaAutodijelovaProvider;

  SearchResult<Grad>? gradResult;
  SearchResult<Uloge>? ulogaResult;
  SearchResult<Autoservis>? autoservisResult;
  SearchResult<FirmaAutodijelova>? firmaResult;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogeProvider = context.read<UlogeProvider>();
    _autoservisProvider = context.read<AutoservisProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
    initForm();
  }

  Future initForm() async {
    gradResult = await _gradProvider.get();
    firmaResult = await _firmaAutodijelovaProvider.get();
    ulogaResult = await _ulogeProvider.get();
    autoservisResult = await _autoservisProvider.get();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.zaposlenik?.ime ?? "Detalji zaposlenika",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : _buildForm(),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildForm() {
  final isAdminOrOwnProfile = context.read<UserProvider>().role == "Admin" || 
      (context.read<UserProvider>().role == "Zaposlenik" && 
       context.read<UserProvider>().userId == widget.zaposlenik!.zaposlenikId);

  return FormBuilder(
    key: _formKey,
    initialValue: {
      'ime': widget.zaposlenik?.ime ?? '',
      'prezime': widget.zaposlenik?.prezime ?? '',
      'brojTelefona': widget.zaposlenik?.brojTelefona?.toString() ?? '',
      'gradId': widget.zaposlenik?.gradId?.toString() ?? '',
      'email': widget.zaposlenik?.email ?? '',
      'username': widget.zaposlenik?.username ?? '',
      'password': widget.zaposlenik?.password ?? '',
      'passwordAgain': widget.zaposlenik?.passwordAgain ?? '',
      'ulogaId': widget.zaposlenik?.ulogaId?.toString() ?? '',
      'autoservisId': widget.zaposlenik?.autoservisId?.toString() ?? '',
      'firmaAutodijelovaId': widget.zaposlenik?.firmaAutodijelovaId?.toString() ?? '',
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Fields
        FormBuilderTextField(
          name: 'ime',
          decoration: InputDecoration(
            labelText: 'Ime',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Unesite ime',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),
        FormBuilderTextField(
          name: 'prezime',
          decoration: InputDecoration(
            labelText: 'Prezime',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Unesite prezime',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),
        FormBuilderTextField(
          name: 'brojTelefona',
          decoration: InputDecoration(
            labelText: 'Broj Telefona',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Unesite broj telefona',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: TextInputType.phone,
          style: TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),

        // Dropdowns
        FormBuilderDropdown<String>(
          name: 'gradId',
          decoration: InputDecoration(
            labelText: 'Izaberite grad',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Izaberite grad',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: TextStyle(color: Colors.black),
          items: gradResult?.result?.map((item) {
            return DropdownMenuItem(
              value: item.gradId.toString(),
              child: Text(item.nazivGrada!, style: TextStyle(color: Colors.black)),
            );
          }).toList() ?? [],
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),
        FormBuilderDropdown<String>(
          name: 'ulogaId',
          decoration: InputDecoration(
            labelText: 'Izaberite ulogu',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Izaberite ulogu',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: TextStyle(color: Colors.black),
          items: ulogaResult?.result?.map((item) {
            return DropdownMenuItem(
              value: item.ulogaId.toString(),
              child: Text(item.nazivUloge!, style: TextStyle(color: Colors.black)),
            );
          }).toList() ?? [],
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),

        // Email and Conditional Inputs
        FormBuilderTextField(
          name: 'email',
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Unesite email',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),

        // Conditional fields for Admin role
        if (isAdminOrOwnProfile) ...[
          FormBuilderTextField(
            name: 'username',
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite korisničko ime',
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: TextStyle(color: Colors.black),
            enabled: isAdminOrOwnProfile,
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Unesite lozinku',
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            obscureText: true,
            style: TextStyle(color: Colors.black),
            enabled: isAdminOrOwnProfile,
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'passwordAgain',
            decoration: InputDecoration(
              labelText: 'Ponovite lozinku',
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Ponovo unesite lozinku',
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            obscureText: true,
            style: TextStyle(color: Colors.black),
            enabled: isAdminOrOwnProfile,
          ),
        ],
        const SizedBox(height: 15),

        // Save button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isAdminOrOwnProfile) 
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      var request = Map.from(_formKey.currentState!.value);
                      request['ulogaId'] = 1; // Set the default role if necessary

                      try {
                        if (widget.zaposlenik == null) {
                          await _zaposlenikProvider.insert(request);
                        } else {
                          await _zaposlenikProvider.update(
                              widget.zaposlenik!.zaposlenikId!,
                              request);
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
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
                  child: const Text("Spasi"),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
