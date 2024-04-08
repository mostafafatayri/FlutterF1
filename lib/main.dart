import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "latest.dart";
import "teams.dart";
import 'drivers.dart';
import "schedual.dart";
import "sign_in.dart";
import 'account_page.dart';
import 'addTeam.dart';
import 'ViewBlog.dart';


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


/*
        menuButton(context, 'testing', Icons.add, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ArticlePage()));} ),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching blogs'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No blogs found'));
          }

          List<Widget> blogCards = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                // Replace 'ViewBlogPage' with the actual page class you're using
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewBlogPage(blogId: doc.id)));
              },
              child: NewsCard(
                title: data['Title'],
                imageUrl: data['ImageURL'],
                category: 'F1 News',
              ),
            );
          }).toList();

          return GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: blogCards,
          );
        },
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


/**
 * import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import "latest.dart";
    import "teams.dart";
    import 'drivers.dart';
    import "schedual.dart";
    import "sign_in.dart";
    import 'account_page.dart';
    import 'addTeam.dart';
    import 'test.dart';


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



    menuButton(context, 'testing', Icons.add, () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ArticlePage()));} ),

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

    body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
    return Center(child: Text('Error fetching blogs'));
    }
    if (!snapshot.hasData) {
    return Center(child: Text('No blogs found'));
    }

    List<NewsCard> blogCards = snapshot.data!.docs.map((doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return NewsCard(
    title: data['Title'],
    imageUrl: data['ImageURL'],
    category: 'F1 News', // You can modify to use a category from data if it exists
    );
    }).toList();

    return GridView.count(
    crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    children: blogCards,
    );
    },
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




 */