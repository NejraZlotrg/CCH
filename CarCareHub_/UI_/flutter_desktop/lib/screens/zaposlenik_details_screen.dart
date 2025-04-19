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
import 'package:flutter_mobile/validation/create_validator.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ZaposlenikDetailsScreen extends StatefulWidget {
  final Zaposlenik? zaposlenik;
  const ZaposlenikDetailsScreen({super.key, this.zaposlenik});

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
  final validator = CreateValidator();

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
  if (context.read<UserProvider>().role == "Admin") {
    gradResult = await _gradProvider.getAdmin();
    firmaResult = await _firmaAutodijelovaProvider.getAdmin();
    ulogaResult = await _ulogeProvider.getAdmin();
    autoservisResult = await _autoservisProvider.getAdmin();}
    else {
    gradResult = await _gradProvider.get();
    firmaResult = await _firmaAutodijelovaProvider.get();
    ulogaResult = await _ulogeProvider.get();
    autoservisResult = await _autoservisProvider.get();}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
        backgroundColor:
            const Color.fromARGB(255, 204, 204, 204), // Siva pozadina
        appBar: AppBar(
          title: Text(widget.zaposlenik?.ime ?? "Detalji zaposlenika"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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


  // Check if it starts with '6' and add '0' if necessary

  return FormBuilder(
    key: _formKey,
    initialValue: {
      'ime': widget.zaposlenik?.ime ?? '',
      'prezime': widget.zaposlenik?.prezime ?? '',
      'brojTelefona': widget.zaposlenik?.brojTelefona ?? '',
      'datumRodjenja': widget.zaposlenik?.datumRodjenja,
      'gradId': widget.zaposlenik?.gradId?.toString() ?? '',
      'email': widget.zaposlenik?.email ?? '',
      'username': widget.zaposlenik?.username ?? '',
      'password': widget.zaposlenik?.password ?? '',
      'passwordAgain': widget.zaposlenik?.passwordAgain ?? '',
      'ulogaId': widget.zaposlenik?.ulogaId?.toString() ?? '',
      'autoservisId': widget.zaposlenik?.autoservisId?.toString() ?? '',
      'firmaAutodijelovaId': widget.zaposlenik?.firmaAutodijelovaId?.toString() ?? '',
      'adresa': widget.zaposlenik?.adresa ?? '',
      'mb' : widget.zaposlenik?.mb ?? ''

    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Fields
        FormBuilderTextField(
          name: 'ime',
          validator: validator.required,
          decoration: const InputDecoration(
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
          style: const TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),

        const SizedBox(height: 15),
 FormBuilderTextField(
          name: 'prezime',
          validator: validator.required,
          decoration: const InputDecoration(
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
          style: const TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),
   FormBuilderTextField(
          name: 'mb',
          validator: validator.required,
          decoration: const InputDecoration(
            labelText: 'JMBG',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Unesite JMBG',
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
          style: const TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),

     
const SizedBox(height: 15),
        
        FormBuilderTextField(
          name: 'brojTelefona',
          validator: validator.phoneNumber,
          decoration: const InputDecoration(
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
          style: const TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        
const SizedBox(height: 15),

FormBuilderDateTimePicker(
  name: 'datumRodjenja',
  inputType: InputType.date,
  format: DateFormat("dd.MM.yyyy"),
  decoration: const InputDecoration(
    labelText: 'Datum rođenja',
    labelStyle: TextStyle(color: Colors.black),
    hintText: 'Odaberite datum rođenja',
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
  style: const TextStyle(color: Colors.black),
  
  validator: validator.required, // dodaj ako je obavezno polje
),
 
const SizedBox(height: 15),
        
        FormBuilderTextField(
          name: 'adresa',
          validator: validator.required,
          decoration: const InputDecoration(
            labelText: 'Adresa',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Unesite adresu',
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
          style: const TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),

        // Dropdowns
        FormBuilderDropdown<String>(
          name: 'gradId',
                   validator: validator.required,
 decoration: const InputDecoration(
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
          style: const TextStyle(color: Colors.black),
          items: gradResult?.result.map((item) {
            return DropdownMenuItem(
  value: item.gradId.toString(),
  child: Text(
    item.nazivGrada ?? "",
    style: TextStyle(
      color: item.vidljivo == false ? Colors.red : Colors.black,
    ),
  ),
);

          }).toList() ?? [],
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),
        
        // Email and Conditional Inputs
        FormBuilderTextField(
          name: 'email',          validator: validator.email,

          decoration: const InputDecoration(
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
          style: const TextStyle(color: Colors.black),
          enabled: isAdminOrOwnProfile,
        ),
        const SizedBox(height: 15),

        // Conditional fields for Admin role
        if (isAdminOrOwnProfile) ...[
          FormBuilderTextField(
            name: 'username',          validator: validator.required,

            decoration: const InputDecoration(
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
            style: const TextStyle(color: Colors.black),
            enabled: isAdminOrOwnProfile,
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'password',          validator: validator.required,

            decoration: const InputDecoration(
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
            style: const TextStyle(color: Colors.black),
            enabled: isAdminOrOwnProfile,
          ),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'passwordAgain',          
            validator: validator.lozinkaAgain,
            decoration: const InputDecoration(
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
            style: const TextStyle(color: Colors.black),
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
                                        "Da li ste sigurni da želite izbrisati ovog zaposlenika?"),
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
                                    await _zaposlenikProvider.delete(
                                        widget.zaposlenik!.zaposlenikId!);
                                    Navigator.pop(context); // Vrati se na prethodni ekran
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Zaposlenik uspješno izbrisan."),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Greška prilikom brisanja: ${e.toString()}"),
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
              if (isAdminOrOwnProfile) 
                ElevatedButton(
               onPressed: () async {
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    var request = Map.from(_formKey.currentState!.value);

                // Konverzija datuma u ISO format
          

          if (request['datumRodjenja'] != null) {
  // Konverzija u ISO 8601 format sa vremenskom zonom
  request['datumRodjenja'] = (request['datumRodjenja'] as DateTime).toUtc().toIso8601String();
  print("Datum rođenja nakon konverzije: ${request['datumRodjenja']}");
}

    request['ulogaId'] = 1; // ili koristi iz dropdown-a ako je dinamički

    try {
      if (widget.zaposlenik == null) {
        await _zaposlenikProvider.insert(request);
      } else {
        await _zaposlenikProvider.update(widget.zaposlenik!.zaposlenikId!, request);
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text("Greška"),
          content: Text("Došlo je do greške prilikom spremanja."),
          actions: [],
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
