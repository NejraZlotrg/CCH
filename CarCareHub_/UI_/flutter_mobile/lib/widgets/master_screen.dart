import 'package:flutter/material.dart';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/screens/autoservis_screen.dart';
import 'package:flutter_mobile/screens/drzave_screen.dart';
import 'package:flutter_mobile/screens/grad_screen.dart';
import 'package:flutter_mobile/screens/klijent_screen.dart';
import 'package:flutter_mobile/screens/model_screen.dart';
import 'package:flutter_mobile/screens/narudzba_screen.dart';
import 'package:flutter_mobile/screens/narudzba_stavka_screen.dart';
import 'package:flutter_mobile/screens/product_screen.dart';
import 'package:flutter_mobile/screens/uloge_screen.dart';
import 'package:flutter_mobile/screens/usluge_screen.dart';
import 'package:flutter_mobile/screens/vozilo_screen.dart';

class MasterScreenWidget extends StatefulWidget {
  final Widget? child;
  final String? title;
  final Widget? titleWidget;

  const MasterScreenWidget({
    this.child,
    this.title,
    this.titleWidget,
    super.key,
  });

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0, // Povećana visina AppBar-a
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back dugme
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 30),
              onPressed: () {
                Navigator.pop(context); // Vraća na prethodnu stranicu
              },
            ),
            // Naslov
            Expanded(
              child: Center(
                child: Text(
                  widget.title ?? "",
                  style: const TextStyle(
                    fontSize: 20, // Veličina fonta
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Shopping cart ikona
            IconButton(
              icon: const Icon(Icons.shopping_cart, size: 30), // Ikona korpe
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NarudzbaStavkaScreen(),
                  ),
                );
              },
            ),
            // Wallet ikona
            IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 30), // Ikona novčanika
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NarudzbaScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
              child: const Text(
                'CarCareHub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Proizvodi'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProductScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Korisnici'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const KlijentScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Država'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DrzaveScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Grad'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GradScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Usluge'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UslugeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Model'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ModelScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vozilo'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VoziloScreen(),
                  ),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Autoservis'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AutoservisScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Uloge'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UlogeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Odjava'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LogInPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: widget.child!,
    );
  }
}
