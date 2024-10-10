//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/provider/kategorija.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/vozilo.dart';
import 'package:flutter_mobile/screens/product_screen.dart';
import 'package:flutter_mobile/screens/registration_page.dart';
import 'package:flutter_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => KategorijaProvider()),
    ChangeNotifierProvider(create: (_) => VoziloProvider()),
    ChangeNotifierProvider(create: (_) => KlijentProvider())
    
  ],
  child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.pink),
        useMaterial3: true,
      ),
      home: LogInPage(),
    );
  }
}

// ignore: must_be_immutable
class LogInPage extends StatelessWidget {
  LogInPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late ProductProvider _productProvider;

  @override
  Widget build(BuildContext context) {
    _productProvider = context.read<ProductProvider>();
    double screenWidth = MediaQuery.of(context).size.width; // Širina ekrana
    double containerWidth = screenWidth * 0.8; // 80% širine ekrana

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'), 
        backgroundColor: Colors.grey[400]
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // 10% sa svake strane
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Image.asset("assets/images/cch_logo.png", height: 100),
                SizedBox(height: 30.0),
                SizedBox(
                  width: containerWidth, // Relativna širina
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Korisničko ime',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: containerWidth,
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Lozinka',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        var username = usernameController.text;
                        var password = passwordController.text;
                       // passwordController.text = username;
                        
                        print('Login: $username, $password');

                        Authorization.username = username;
                        Authorization.password = password;

                        try {
                          await _productProvider.get();
  
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=> ProductScreen() // poziv na drugi screen
                          ),
                          );
                        } on Exception catch (e) {
                          showDialog(context: context, 
                          builder: (BuildContext context) => AlertDialog(
                            title: Text("error"),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
                            ],
                          ));
                        }
                      },
                      child: Text('Login'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print("Registration proceed"); // dio sto pise u terminalu
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=> RegistrationPage() // poziv na drugi screen
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

               

class LayoutExamples extends StatelessWidget {
  const LayoutExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Container(
          height: 200,
          color: Colors.red,
          child: Center(
            child: Container(
              height: 100,
              width: 700,
              color: Colors.blue,
              child: const Text('simple text'), 
            ),
          ),
        ),
        Row( mainAxisAlignment: MainAxisAlignment.spaceAround, 
        children: [
          Text("1"), 
          Text("2"),
          Text("3")],
        ),
        Container(height: 150,
        color: Colors.pink, 
        child: Center(child: Text("Ali nešša"),),
        )
        
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}