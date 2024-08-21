//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/product.dart';
//import 'package:flutter_mobile/widgets/master_screen.dart';


class RegistrationPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Širina ekrana
    double containerWidth = screenWidth * 0.8; // 80% širine ekrana

        return Scaffold(
      appBar: AppBar(
        title: Text('Registracija'), 
        backgroundColor: Colors.grey[400]
      ),
      body:  Center(

        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[400], // Tamnija siva pozadina za centralni dio
              borderRadius: BorderRadius.circular(8.0), // Zaobljeni uglovi
            ),
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // 10% sa svake strane
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/cch_logo.png", height: 100),
                SizedBox(height: 30.0),
                SizedBox(
                  width: containerWidth, // Relativna širina
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: containerWidth, // Relativna širina
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Lozinka',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: containerWidth, // Relativna širina
                  child: TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Potvrdi lozinku',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                       onPressed: () {
                        print("Proizvodi proceed"); // dio sto pise u terminalu
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=> ProductScreen() // poziv na drugi screen
                        ),
                        );
                      },
                      child: Text('Registruj se'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
