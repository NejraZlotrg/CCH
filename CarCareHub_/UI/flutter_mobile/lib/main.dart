import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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

class LogInPage extends StatelessWidget {
 LogInPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300], // Svjetlija siva pozadina
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[400], // Tamnija siva pozadina za centralni dio
            borderRadius: BorderRadius.circular(8.0), // Zaobljeni uglovi
          ),
          margin: EdgeInsets.symmetric(horizontal: 260.0), // Sužavanje centralnog dijela
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.file(
                File('C:/Users/alika/Desktop/cch.transparent.png'),
                height: 100,
              ),
              SizedBox(height: 30.0),
              SizedBox(
                width: 500.0, // Postavite željenu širinu
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Korisničko ime',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white, // Bijela pozadina za polje unosa
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: 500.0, // Postavite željenu širinu
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      String username = usernameController.text;
                      String password = passwordController.text;
                      print('Prijava: $username, $password');
                    },
                    child: Text('Prijavi se'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
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

class RegistrationPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300], // Svjetlija siva pozadina
       appBar: AppBar(
        title: Text('Registracija'),
      ),
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[400], // Tamnija siva pozadina za centralni dio
            borderRadius: BorderRadius.circular(8.0), // Zaobljeni uglovi
          ),
          margin: EdgeInsets.symmetric(horizontal: 260.0), // Sužavanje centralnog dijela
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.file(
                File('C:/Users/alika/Desktop/cch.transparent.png'),
                height: 100,
              ),
              SizedBox(height: 30.0),
              SizedBox(
                width: 500.0, // Postavite željenu širinu
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white, // Bijela pozadina za polje unosa
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              SizedBox(
                width: 500.0, // Postavite željenu širinu
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Lozinka',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white, // Bijela pozadina za polje unosa
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: 500.0, // Postavite željenu širinu
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
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
