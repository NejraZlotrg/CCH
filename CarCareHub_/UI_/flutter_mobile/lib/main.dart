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
import 'package:flutter_mobile/provider/kategorija_provider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/korpa_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/narudzba_stavka_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/placanje_provider.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
      defaultValue: "pk_test_51Qgz9yCdZMYTHaMlBcpXvZmiujxacKPAz49IXxSYChj3gv2lG5HJJCM2kqeJNEctQXSRAevbENhGTqlkvYW460wi00ZMCqgmp0");

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
        ChangeNotifierProvider(create: (_) => BPAutodijeloviAutoservisProvider()),
        ChangeNotifierProvider(create: (_) => KorpaProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatAutoservisKlijentProvider()),
        ChangeNotifierProvider(create: (_) => ChatKlijentZaposlenikProvider()),
        ChangeNotifierProvider(create: (_) => PlacanjeProvider()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LogInPage(),
    );
  }
}

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/cch_logo.png", height: 80),
              const SizedBox(height: 20),
              const Text(
                'Dobrodošli u Car Care Hub!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Prijavite se kako biste nastavili.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              _buildTextField(usernameController, 'Korisničko ime'),
              const SizedBox(height: 15),
              _buildTextField(passwordController, 'Lozinka', obscureText: true),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Text(errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var username = usernameController.text;
                  var password = passwordController.text;

                  Authorization.username = username;
                  Authorization.password = password;

                  try {
                    final autoservisProvider = AutoservisProvider();
                    final zaposlenikProvider = ZaposlenikProvider();
                    final klijentProvider = KlijentProvider();
                    final firmaAutodijelovaProvider = FirmaAutodijelovaProvider();

                    final userIdA = await autoservisProvider.getIdByUsernameAndPassword(username, password);
                    final vidljivoA = await autoservisProvider.getVidljivoByUsernameAndPassword(username, password);

                    final userIdZ = await zaposlenikProvider.getIdByUsernameAndPassword(username, password);
                    final vidljivoZ = await zaposlenikProvider.getVidljivoByUsernameAndPassword(username, password);

                    final userIdK = await klijentProvider.getIdByUsernameAndPassword(username, password);
                    final vidljivoK = await klijentProvider.getVidljivoByUsernameAndPassword(username, password);

                    final userIdF = await firmaAutodijelovaProvider.getIdByUsernameAndPassword(username, password);
                    final vidljivoF = await firmaAutodijelovaProvider.getVidljivoByUsernameAndPassword(username, password);

                    final userProvider = context.read<UserProvider>();

                    if (userIdA != null && vidljivoA == true) {
                      userProvider.setUser(userIdA, 'Autoservis', username);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductScreen()));
                    } else if (userIdZ != null && vidljivoZ == true) {
                      userProvider.setUser(userIdZ, 'Zaposlenik', username);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductScreen()));
                    } else if (userIdK != null && vidljivoK == true) {
                      userProvider.setUser(userIdK, userIdK == 2 ? 'Admin' : 'Klijent', username);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductScreen()));
                    } else if (userIdF != null && vidljivoF == true) {
                      userProvider.setUser(userIdF, 'Firma autodijelova', username);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductScreen()));
                    } else {
                      setState(() {
                        errorMessage = "Korisnik nije pronađen ili je deaktiviran.";
                      });
                    }
                  } catch (e) {
                    setState(() {
                      errorMessage = "Greška prilikom prijave. Pokušajte ponovo.";
                    });
                  }
                },
                child: const Text("Prijavi se"),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Registruj se kao:"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRegistrationOption(
                            icon: Icons.store,
                            text: "Firma autodijelova",
                            screen: FirmaAutodijelovaRegistracijaScreen(firmaAutodijelova: null),
                          ),
                          _buildRegistrationOption(
                            icon: Icons.build,
                            text: "Autoservis",
                            screen: AutoservisRegistracijaScreen(autoservis: null),
                          ),
                          _buildRegistrationOption(
                            icon: Icons.person,
                            text: "Klijent",
                            screen: KlijentRegistracijaScreen(klijent: null),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text("Registruj se"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRegistrationOption({required IconData icon, required String text, required Widget screen}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
    );
  }
}
