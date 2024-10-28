import 'package:flutter/material.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/drzave_provider.dart';
import 'package:flutter_mobile/provider/firmaautodijelova_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/model_provider.dart';
import 'package:flutter_mobile/provider/narudzba_stavka_provider.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/uloge_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/provider/vozilo_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/screens/product_screen.dart';
import 'package:flutter_mobile/screens/registration_page.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: const Color.fromARGB(255, 84, 83, 83)),
        useMaterial3: true,
      ),
      home: LogInPage(),
    );
  }
}

class LogInPage extends StatefulWidget {
  LogInPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage; // Poruka greške koja će se prikazati ako login ne uspije

  @override
  Widget build(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    double containerWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: containerWidth,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left two-thirds with login form
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30.0),
                        _buildTextField(usernameController, 'Korisničko ime'),
                        const SizedBox(height: 15.0),
                        _buildTextField(passwordController, 'Lozinka', obscureText: true),
                        const SizedBox(height: 10.0),
                        if (errorMessage != null) // Prikaz poruke o grešci
                          Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                var username = usernameController.text;
                                var password = passwordController.text;
                                Authorization.username = username;
                                Authorization.password = password;

                                try {
                                  await productProvider.get();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProductScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    errorMessage = "Neuspješna prijava. Provjerite podatke i pokušajte ponovo.";
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.black),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              ),
                              child: const Text(
                                'Prijava',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RegistrationPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              ),
                              child: const Text(
                                'Registruj se',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Right one-third with logo and details
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/cch_logo.png",
                          height: 100,
                        ),
                        const SizedBox(height: 20.0),
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
                        const SizedBox(height: 20.0),
                        Icon(
                          Icons.directions_car_filled_outlined,
                          size: 40,
                          color: const Color.fromARGB(255, 66, 65, 65),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return SizedBox(
      width: 370, // Narrower input field
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
