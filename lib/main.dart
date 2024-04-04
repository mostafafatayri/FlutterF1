import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import "latest.dart";
import "teams.dart";
import 'drivers.dart';
import "schedual.dart";
import "sign_in.dart";
import 'account_page.dart';
import 'addTeam.dart';
//import 'details.dart';
//import  'addTrack.dart';
import 'fullRaceDetails.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyD58LLRg3w7qoczhtSxuHqGL-mOCKh7czs",
        projectId: "newstart-d7387",
        messagingSenderId: "343416576890",
        appId: "1:343416576890:web:2eab66123c5f05616dd4c3",
       storageBucket: "newstart-d7387.appspot.com",
    ),
  );


  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula 1 Mini Site',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,//here to stop flag
      home: F1HomePage(),
    );
  }
}

// this is
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return SignInRegisterPage(); // User not signed in, show sign-in page
          } else {
            return AccountPage(); // User is signed in, show account page
          }
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()), // Loading indicator
        );
      },
    );
  }
}

//

class F1HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          width: double.infinity,
          height: kToolbarHeight,
          color: Color(0xFFD50000),
          child: Image.asset('image2.png', fit: BoxFit.contain),
        ),
        backgroundColor: Color(0xFFD50000),
        actions: <Widget>[



       /*  menuButton(context, 'testing', Icons.add, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RaceWeekendPage()));} ),
*/
          FutureBuilder<DocumentSnapshot>(
            future: _getAdminStatus(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();  // Show loading indicator
              } else if (snapshot.hasError) {
                return Text('');
              } else if (snapshot.data?.exists == true && snapshot.data?['Admin'] == true) {
                // If admin, show the button
                return menuButton(context, 'Admin Portal', Icons.add, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddF1TeamPage()));
                });
              } else {
                // If not admin, don't show the button or replace with a placeholder
                return Container();  // Empty container if not admin
              }
            },
          ),
          menuButton(context, 'Schedule', Icons.calendar_today, ()  {
            Navigator.push(context, MaterialPageRoute(builder: (context) => F1SchedulePage()));} ),

         /* menuButton(context, 'Add F1 Team', Icons.add, () { //assessment
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddF1TeamPage()));
          }),   // only for admin
*/
          menuButton(context, 'Teams', Icons.assessment, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => F1Teams2024Page()));} ),

          menuButton(context, 'Drivers', Icons.person, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => F1DriversPage()));} ),

        /*  menuButton(context, 'Teams details', Icons.group, () { //assessment
            Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDetailsPage()));
          }),*/



          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthenticationWrapper()),
              );
            },
          ),

        ],
      ),
      body: Center(
        child: Text('F1 Content Goes Here'),
      ),
    );
  }
  Future<DocumentSnapshot> _getAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetching the user document based on the email
      var userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.email).get();

      // Adding print statements for debugging
      print("User email: ${user.email}");
      print("Admin status from Firestore: ${userDoc.data()}");

      if (!userDoc.exists) {
        print("User document does not exist in 'Users' collection.");
      } else if (userDoc.data()?['Admin'] != true) {
        print("User is not an admin.");
      }

      return userDoc;
    } else {
      print("No user is currently signed in.");
      throw FirebaseAuthException(code: 'NOT-LOGGED-IN', message: 'User is not logged in.');
    }
  }





  Widget menuButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return TextButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: TextStyle(color: Colors.white)),
      onPressed: onPressed,
    );
  }
}




/*
* import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyD58LLRg3w7qoczhtSxuHqGL-mOCKh7czs",
        projectId: "newstart-d7387",
        messagingSenderId: "343416576890",
        appId: "1:343416576890:web:2eab66123c5f05616dd4c3",

       // authDomain: "newstart-d7387.firebaseapp.com",
      //  storageBucket: "newstart-d7387.appspot.com",
     //   measurementId: "G-3588CVJ14L"
    ),
  );

  try {
    // FirebaseAuth auth = FirebaseAuth.instance;
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "mostafa@newtest32.com",
      password: '123456',
    );
    print("The user is being created:");
  } catch (e) { // Catching a more generic exception
    if (e is FirebaseException) {
      print("Firebase Error: ${e.message}");

    } else {
      print("An unexpected error occurred:  test one $e");

    }
  }
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
*/
