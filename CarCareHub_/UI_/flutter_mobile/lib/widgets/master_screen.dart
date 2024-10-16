import 'package:flutter/material.dart';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/screens/drzave_screen.dart';
import 'package:flutter_mobile/screens/grad_screen.dart';
import 'package:flutter_mobile/screens/klijent_screen.dart';
import 'package:flutter_mobile/screens/model_screen.dart';
import 'package:flutter_mobile/screens/product_screen.dart';
import 'package:flutter_mobile/screens/usluge_screen.dart';
import 'package:flutter_mobile/screens/vozilo_screen.dart';
//import 'package:flutter_mobile/screens/registracija.dart';

class MasterScreenWidget extends StatefulWidget {
  final Widget? child;
  final String? title;
  final Widget? title_widget;
  const MasterScreenWidget({this.child, this.title, this.title_widget, super.key});

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title_widget ?? Text(widget.title ?? ""),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],

      ),
       drawer: Drawer(   //treba linkovati na screenove
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
                    builder: (context)=> const ProductScreen()
                    ),
                );
              }
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Korisnici'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context)=> const KlijentScreen()
                    ),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Drzava'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context)=> const DrzaveScreen()
                    ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Grad'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context)=> const GradScreen()
                    ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Usluge'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context)=> const UslugeScreen()
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
                    builder: (context)=> ModelScreen()
                    ),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Vozilo'),
              onTap: () {
                  Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context)=> VoziloScreen()
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
                    builder: (context)=> LogInPage()
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