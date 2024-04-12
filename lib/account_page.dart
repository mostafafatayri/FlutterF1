import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import "sign_in.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "URAPI",
      projectId: "URID",
      messagingSenderId: "URSENDERID",
      appId: "YourAppID",
    ),
  );
  runApp(AccountPage());
}

class AccountPage extends StatefulWidget {

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Initialize with empty strings
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController birthdayController = TextEditingController(
      text: ''); // You might not get this from Firebase Auth
  TextEditingController countryController = TextEditingController(
      text: ''); // You might not get this from Firebase Auth
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(
      text: '********'); // You should not display the password

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

//future for the savename
  Future<void> saveName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (emailController.text.isNotEmpty) {
      try {
        var userQuery = await FirebaseFirestore.instance.collection('Users')
            .where('email', isEqualTo: emailController.text)
            .get();
        if (userQuery.docs.isNotEmpty) {
          var doc = userQuery.docs.first;
          await FirebaseFirestore.instance.collection('Users')
              .doc(doc.id)
              .update({
            'fullName': nameController.text,
          });
          print("Name updated for ${emailController.text}");
        } else {
          print("No user found with email ${emailController.text}");
        }
      } catch (e) {
        print("Error updating name: $e");
      }
    }
  }


  Future<void> saveCountry() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (emailController.text.isNotEmpty) {
      try {
        var userQuery = await FirebaseFirestore.instance.collection('Users')
            .where('email', isEqualTo: emailController.text)
            .get();
        if (userQuery.docs.isNotEmpty) {
          var doc = userQuery.docs.first;
          await FirebaseFirestore.instance.collection('Users')
              .doc(doc.id)
              .update({
            'Country': countryController.text,
          });
          print("Name updated for ${emailController.text}");
        } else {
          print("No user found with email ${emailController.text}");
        }
      } catch (e) {
        print("Error updating name: $e");
      }
    }
  }

  Future<void> saveBirthday() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (emailController.text.isNotEmpty) {
      try {
        var userQuery = await FirebaseFirestore.instance.collection('Users')
            .where('email', isEqualTo: emailController.text)
            .get();
        if (userQuery.docs.isNotEmpty) {
          var doc = userQuery.docs.first;
          await FirebaseFirestore.instance.collection('Users')
              .doc(doc.id)
              .update({
            'birthday': birthdayController.text,
          });
          print("Name updated for ${emailController.text}");
        } else {
          print("No user found with email ${emailController.text}");
        }
      } catch (e) {
        print("Error updating name: $e");
      }
    }
  }


  //

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email ??
          'No Email'; // Default value or handling if email is null
      print("Hello World: $userEmail");
      // Set the email
      emailController.text = user.email ?? '';
      // For demonstration, using the email's local part as the user's name
      nameController.text = user.email!.split('@').first;

      /// the query to db is
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Users').where('email', isEqualTo: userEmail)
            .get();
        // print("the data is $querySnapshot");
        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data() as Map<String,
              dynamic>;
          print("the data is $userData");
          nameController.text = userData['fullName'] ?? 'No Name';
          birthdayController.text = userData['birthday'] ?? 'No Birthday';
          countryController.text = userData['Country'] ?? 'No Country';

          // Note: Email is already set from FirebaseAuth user
        }
        else {
          try {
            await FirebaseFirestore.instance.collection('Users')
                .doc(userEmail)
                .set({
              'fullName': nameController.text,
              // Use data from your TextControllers or some default values
              'email': userEmail,
              // User's email
              'birthday': '',
              // Some default value or from a TextController
              'Country': '',
              'Admin':false
              // Some default value or from a TextController
              // Add more fields as necessary
            });
            print("New user data created for $userEmail");
          } catch (e) {
            print("Error creating user data: $e");
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
        // Handle the error or show a message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        backgroundColor: Color(0xFFD50000),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PERSONAL INFORMATION', style: Theme
                  .of(context)
                  .textTheme
                  .headline6),
              Divider(),
              editableListTile('Email address', emailController, showSaveButton: false),
              editableListTile('Name', nameController),
              editableListTile('Birthday', birthdayController),
              editableListTile('Country of residence', countryController),
              editableListTile('Password', passwordController),
              Row(
                children: [
                  Checkbox(
                    value: true, // this should be your state variable
                    onChanged: (bool? newValue) {
                      // handle checkbox change
                    },
                  ),
                  Expanded(
                    child: Text(
                        'I want to receive the latest information from F1® including relevant news, surveys, offers, and exclusive competitions.'),
                  ),
                ],
              ),
              TextButton(
                child: Text('Terms and Conditions and Privacy Policy'),
                onPressed: () {
                  // Open T&C and privacy policy
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('LOG OUT'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // After logging out, return to the SignInRegisterPage or another appropriate page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => SignInRegisterPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD50000), // button color
                  foregroundColor: Colors.white, // text color
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget editableListTile(String title, TextEditingController controller,
      {bool showSaveButton = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 15, vertical: 10),
              labelText: 'Edit $title',
            ),
            // If you want to make the email field read-only, add this line
            readOnly: title == 'Email address',
          ),
          // Conditionally display the Save button
          if (showSaveButton) Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: Text('Save'),
              onPressed: () {
                // Call the appropriate save function based on the field
                switch (title) {
                  case 'Name':
                    saveName();
                    break;
                  case 'Birthday':
                    saveBirthday();
                    break;
                  case 'Country of residence':
                    saveCountry();
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
