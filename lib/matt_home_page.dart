import 'package:flutter/material.dart';


class matthomepage extends StatelessWidget {
  const matthomepage({super.key});

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  //Ian Waskom

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: Center(
     
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Liars Bar IRL:',
            ),
const SizedBox(height: 30),
  ElevatedButton(
    onPressed: () {
      // Handle Play LAN action
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF461D7C),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    ),
    child: const Text(
      'Play LAN',
      style: TextStyle(fontSize: 18),
    ),
  ),
  const SizedBox(height: 20),
  ElevatedButton(
    onPressed: () {
      // Handle Play AI action
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF461D7C),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    ),
    child: const Text(
      'Play AI',
      style: TextStyle(fontSize: 18),
    ),
  ),
],

        ),
      ),
 
      // This trailing comma makes auto-formatting nicer for build methods.
       bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF461D7C),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'MAIN MENU',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'RULES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}







// Hunter Todd wuz here




// Matthew Balachowski 
// Matthew Balachowski pt 2
//Samuel A. Bustamante






//Maycie Pinell
// Steven Reed
//Jacob Rodrigue
//julia
//Kollin
//Christian
