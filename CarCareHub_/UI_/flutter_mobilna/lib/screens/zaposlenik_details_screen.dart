import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/main.dart';
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
String? selectedAutoservisId;
String? selectedFirmaId;
  bool isLoading = true;

   bool _usernameExists = false;
  final validator = CreateValidator();

  @override
  void initState() {
    super.initState();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogeProvider = context.read<UlogeProvider>();
    _autoservisProvider = context.read<AutoservisProvider>();
    _firmaAutodijelovaProvider = context.read<FirmaAutodijelovaProvider>();
      selectedAutoservisId = widget.zaposlenik?.autoservisId?.toString();
  selectedFirmaId = widget.zaposlenik?.firmaAutodijelovaId?.toString();
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
  'mb': widget.zaposlenik?.mb ?? ''
},
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Fields
        FormBuilderTextField(
          name: 'ime',
          validator: validator.prezime,
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
          validator: validator.prezime,
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
          validator: validator.numberWith12DigitsOnly,
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
          validator: validator.adresa,
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
          name: 'email',         
           validator: validator.email,

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
  name: 'username',
 
validator: (value) {
    final error = validator.username3char(value); // koristi tvoju funkciju
    if (error != null) return error;

    if (_usernameExists) {
      return 'Korisničko ime već postoji';
    }

    return null;
  },
 

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
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    errorStyle: TextStyle(color: Colors.red),
  ),
  style: const TextStyle(color: Colors.black),
  enabled: isAdminOrOwnProfile,
 onChanged: (value) {
    if (value != null && value.isNotEmpty) {
      setState(() {
        _usernameExists = false;
      });
      _formKey.currentState?.fields['username']?.validate();
    }
  },
),
          const SizedBox(height: 15),
          FormBuilderTextField(
            name: 'password',          validator: validator.password,

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
   
FormBuilderDropdown<String>(
  name: 'autoservisId',
  decoration: const InputDecoration(
    labelText: 'Izaberite autoservis',
    labelStyle: TextStyle(color: Colors.black),
    hintText: 'Izaberite autoservis',
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
  items: [
    const DropdownMenuItem(
      value: '',
      child: Text('Izaberi autoservis', style: TextStyle(color: Colors.grey)),
    ),
    ...?autoservisResult?.result.map((item) {
      return DropdownMenuItem(
        value: item.autoservisId.toString(),
        child: Text(
          item.naziv ?? "",
          style: TextStyle(
            color: item.vidljivo == false ? Colors.red : Colors.black,
          ),
        ),
      );
    }),
  ],
  enabled: isAdminOrOwnProfile && (selectedFirmaId == '' || selectedFirmaId==null), // Omogući ako firma nije odabrana
  onChanged: (value) {
    setState(() {
      selectedAutoservisId = value ?? ''; // Ako nije odabrano, setuj na prazno
      if (value != '') selectedFirmaId = ''; // Resetuj firmu ako je odabran autoservis
    });
  },
),

const SizedBox(height: 15),

FormBuilderDropdown<String>(
  name: 'firmaAutodijelovaId',
  decoration: const InputDecoration(
    labelText: 'Izaberite firmu autodijelova',
    labelStyle: TextStyle(color: Colors.black),
    hintText: 'Izaberite firmu autodijelova',
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
  items: [
    const DropdownMenuItem(
      value: '',
      child: Text('Izaberi firmu autodijelova', style: TextStyle(color: Colors.grey)),
    ),
    ...?firmaResult?.result.map((item) {
      return DropdownMenuItem(
        value: item.firmaAutodijelovaID.toString(),
        child: Text(
          item.nazivFirme ?? "",
          style: TextStyle(
            color: item.vidljivo == false ? Colors.red : Colors.black,
          ),
        ),
      );
    }),
  ],
  enabled: isAdminOrOwnProfile && (selectedAutoservisId == '' || selectedAutoservisId==null), // Omogući ako autoservis nije odabrana
  onChanged: (value) {
    setState(() {
      selectedFirmaId = value ?? ''; // Ako nije odabrano, setuj na prazno
      if (value != '') selectedAutoservisId = ''; // Resetuj autoservis ako je odabrana firma
    });
  },
),


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
                                      final userProvider = context.read<UserProvider>();
      final isOwnAccount = userProvider.role == "Klijent" &&    userProvider.userId == widget.zaposlenik?.zaposlenikId;
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

                                if (confirmDelete == true) {
        try {
          await _zaposlenikProvider.delete(widget.zaposlenik!.zaposlenikId!);

          if (isOwnAccount) {
            // Logout i navigacija na login screen
         
         Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LogInPage(),
                  ),
                );
          } else {
            Navigator.pop(context); // Vrati se na prethodni ekran
          }
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

    // Provjera username-a
    final username = request['username'];
    if (username != null && username.toString().isNotEmpty) {
      final exists = await _zaposlenikProvider.checkUsernameExists(username);
      if (exists && (widget.zaposlenik == null || 
          widget.zaposlenik?.username?.toLowerCase() != username.toLowerCase())) {
        setState(() {
          _usernameExists = true;
        });
        _formKey.currentState?.fields['username']?.validate();
        return;
      }
    }

  final autoservisId = _formKey.currentState?.fields['autoservisId']?.value;
  final firmaId = _formKey.currentState?.fields['firmaAutodijelovaId']?.value;

  if ((autoservisId == null || autoservisId == '') &&
      (firmaId == null || firmaId == '')) {
    // Prikaži poruku ako nijedno nije odabrano
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Morate odabrati ili autoservis ili firmu autodijelova.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

    // Convert date to ISO format
    if (request['datumRodjenja'] != null) {
      request['datumRodjenja'] = (request['datumRodjenja'] as DateTime).toIso8601String();
    }

    // Convert dropdown string values to integers
    if (request['gradId'] != null) {
      request['gradId'] = int.tryParse(request['gradId']);
    }

    request['ulogaId'] = 1;

    // Handle autoservisId and firmaAutodijelovaId - only send one of them
    if (selectedAutoservisId != null && selectedAutoservisId!.isNotEmpty) {
      request['autoservisId'] = int.tryParse(selectedAutoservisId!);
      request['firmaAutodijelovaId'] = null;
    } else if (selectedFirmaId != null && selectedFirmaId!.isNotEmpty) {
      request['firmaAutodijelovaId'] = int.tryParse(selectedFirmaId!);
      request['autoservisId'] = null;
    } else {
      request['autoservisId'] = null;
      request['firmaAutodijelovaId'] = null;
    }

    try {
      if (widget.zaposlenik == null) {
        await _zaposlenikProvider.insert(request);
      } else {
        await _zaposlenikProvider.update(widget.zaposlenik!.zaposlenikId!, request);
      }

      Navigator.pop(context);
    } catch (e) {
      // Ovdje možete prikazati grešku u polju umjesto dialoga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Došlo je do greške: ${e.toString()}"),
          backgroundColor: Colors.red,
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
