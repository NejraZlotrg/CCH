// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';

import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/godiste_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/narudzba_stavka_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/proizvodjac_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/screens/autoservis_details_screen.dart';
import 'package:flutter_mobile/screens/autoservis_registracija_screen.dart';
import 'package:flutter_mobile/screens/firma_autodijelova_registracija_screen.dart';
import 'package:flutter_mobile/screens/firmaautodijelova_details_screen.dart';
import 'package:flutter_mobile/screens/klijent_details_screen.dart';
import 'package:flutter_mobile/screens/klijent_registracija_screen.dart';
import 'package:flutter_mobile/screens/product_screen.dart';
import 'package:flutter_mobile/screens/registration_page.dart';
import 'package:flutter_mobile/screens/zaposlenik_details_screen.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() {
  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
      defaultValue:
          "pk_test_51Qgz9yCdZMYTHaMlBcpXvZmiujxacKPAz49IXxSYChj3gv2lG5HJJCM2kqeJNEctQXSRAevbENhGTqlkvYW460wi00ZMCqgmp0");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => KategorijaProvider()),
        ChangeNotifierProvider(create: (_) => VoziloProvider()),
        ChangeNotifierProvider(create: (_) => KlijentProvider()),
        ChangeNotifierProvider(create: (_) => DrzaveProvider()),
        ChangeNotifierProvider(create: (_) => GradProvider()),
        ChangeNotifierProvider(create: (_) => UslugeProvider()),
        ChangeNotifierProvider(create: (_) => ModelProvider()),
        ChangeNotifierProvider(create: (_) => NarudzbaProvider()),
        ChangeNotifierProvider(create: (_) => NarudzbaStavkeProvider()),
        ChangeNotifierProvider(create: (_) => AutoservisProvider()),
        ChangeNotifierProvider(create: (_) => UlogeProvider()),
        ChangeNotifierProvider(create: (_) => FirmaAutodijelovaProvider()),
        ChangeNotifierProvider(create: (_) => ZaposlenikProvider()),
        ChangeNotifierProvider(create: (_) => ProizvodjacProvider()),
        ChangeNotifierProvider(create: (_) => GodisteProvider()),
        ChangeNotifierProvider(
            create: (_) => BPAutodijeloviAutoservisProvider()),
        ChangeNotifierProvider(create: (_) => KorpaProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatAutoservisKlijentProvider()),
        ChangeNotifierProvider(create: (_) => ChatKlijentZaposlenikProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Care Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: const Color.fromARGB(255, 84, 83, 83)),
        useMaterial3: true,
      ),
      home: const LogInPage(),
    );
  }
}

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogInPageState createState() => _LogInPageState();
}
class _LogInPageState extends State<LogInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: containerWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/cch_logo.png",
                        height: 80,
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Dobrodošli u Car Care Hub!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Brinemo o vašem vozilu s ljubavlju i pažnjom.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      const Icon(
                        Icons.directions_car_filled_outlined,
                        size: 40,
                        color: Color.fromARGB(255, 66, 65, 65),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Prijavite se na svoj račun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Unesite vaše podatke da biste pristupili aplikaciji.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30.0),
                      _buildTextField(usernameController, 'Korisničko ime'),
                      const SizedBox(height: 15.0),
                      _buildTextField(passwordController, 'Lozinka',
                          obscureText: true),
                      const SizedBox(height: 10.0),
                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                var username = usernameController.text;
                                var password = passwordController.text;

                                // Pohranjujemo korisničke podatke u Authorization
                                Authorization.username = username;
                                Authorization.password = password;

                              try {
  // Inicijalizacija providera
  final autoservisProvider = AutoservisProvider();
  final zaposlenikProvider = ZaposlenikProvider();
  final klijentProvider = KlijentProvider();
  final firmaAutodijelovaProvider = FirmaAutodijelovaProvider();

  // Provjera userId kroz sve providere
  final userIdA = await autoservisProvider.getIdByUsernameAndPassword(username, password);
  final userIdZ = await zaposlenikProvider.getIdByUsernameAndPassword(username, password);
  final userIdK = await klijentProvider.getIdByUsernameAndPassword(username, password);
  final userIdF = await firmaAutodijelovaProvider.getIdByUsernameAndPassword(username, password);

  // Provjera svih korisnika
  if (userIdA != null) {
    final userProvider = context.read<UserProvider>();
    userProvider.setUser(userIdA, 'Autoservis', username);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductScreen(),
      ),
    );
  } else if (userIdZ != null) {
    final userProvider = context.read<UserProvider>();
    userProvider.setUser(userIdZ, 'Zaposlenik', username);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductScreen(),
      ),
    );
  } else if (userIdK != null) {
    final userProvider = context.read<UserProvider>();
    if (userIdK == 2) {
      userProvider.setUser(userIdK, 'Admin', username);
    } else {
      userProvider.setUser(userIdK, 'Klijent', username);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductScreen(),
      ),
    );
  } else if (userIdF != null) {
    final userProvider = context.read<UserProvider>();
    userProvider.setUser(userIdF, 'Firma autodijelova', username );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductScreen(),
      ),
    );
  }
else {
    // Ako userId nije pronađen, prikazujemo grešku
    setState(() {
      errorMessage = "Korisnik nije pronađen. Provjerite svoje podatke i pokušajte ponovo.";
    });
  }}
catch (e) {
  // Obrada grešaka
  setState(() {
    errorMessage = "Došlo je do greške prilikom prijave. Pokušajte ponovo.";
  });
}
},

                              child: const Text("Prijavi se"),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Registruj se kao:"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.store),
                                            title: const Text(
                                                "Firma autodijelova"),
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Zatvaranje dijaloga
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FirmaAutodijelovaRegistracijaScreen(
                                                          firmaAutodijelova:
                                                              null,
                                                        ) // poziv na drugi screen
                                                    ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.store),
                                            title: const Text("Autoservis"),
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Zatvaranje dijaloga
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AutoservisRegistracijaScreen(
                                                          autoservis: null,
                                                        ) // poziv na drugi screen
                                                    ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.store),
                                            title: const Text("Klijent"),
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Zatvaranje dijaloga
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        KlijentRegistracijaScreen(
                                                          klijent: null,
                                                        ) // poziv na drugi screen
                                                    ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 24),
                              ),
                              child: const Text(
                                'Registruj se',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        obscureText: obscureText,
      ),
    );
  }
}