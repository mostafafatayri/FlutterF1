import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "YourKeys",
      projectId: "YourID",
      messagingSenderId: "ID",
      appId: "UrAppID",
    ),
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("the app is being build :");
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInRegisterPage(),
    );
  }
}

class SignInRegisterPage extends StatefulWidget {
  @override
  _SignInRegisterPageState createState() => _SignInRegisterPageState();
}

class _SignInRegisterPageState extends State<SignInRegisterPage> {
  bool showSignIn = true;
  final _formKey = GlobalKey<FormState>();

  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _agreeTerms = false;

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  ///print("the app is being build : for the check of it");
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _signInEmailController.text.trim(),
          password: _signInPasswordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged in')));
        // Navigate to your home screen
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
      }
    }
  }

  Future<void> _register() async {
    print("the email : "+_registerEmailController.text.trim()+" the passs: "+_registerPasswordController.text);
    if (_formKey.currentState!.validate() && _agreeTerms) {
      print("test before send ");
      try {
        // FirebaseAuth auth = FirebaseAuth.instance;
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created successfully")));
        print("The user is being created:");
      } catch (e) { // Catching a more generic exception
        if (e is FirebaseException) {
          print("Firebase Error: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred with Firebase')));
        } else {
          print("An unexpected error occurred:  test one $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred')));
        }
      }
    } else if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You must agree to the terms and conditions')));
    }
  }


  @override
  Widget build(BuildContext context) {
    print("the app is being build : in the widget :");
    return Scaffold(
      appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: kToolbarHeight,
            color: Color(0xFFD50000),
            child: Image.asset('image2.png', fit: BoxFit.contain),
          ),
        actions: <Widget>[
          TextButton(
            onPressed: _toggleForm,
            child: Text(showSignIn ? 'Register' : 'Sign In', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (showSignIn) ...[
                    TextFormField(
                      controller: _signInEmailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Please enter a valid email' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _signInPasswordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty || value.length < 6) ? 'Password must be at least 6 characters' : null,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: Text('Sign In'),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _registerEmailController,
                      decoration: InputDecoration(labelText: 'Email Address'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Please enter a valid email' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _registerPasswordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty || value.length < 6) ? 'Password must be at least 6 characters' : null,
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _agreeTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Implement navigation to your terms and conditions here
                            },
                            child: Text(
                              'I agree to the Terms and Conditions',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _agreeTerms ? _register : null, // Only allow registration if terms are agreed
                      child: Text('Register'),
                    ),
                  ],
                ]),
          ),
        ),
      ),
    );
  }
}



/**import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:firebase_auth/firebase_auth.dart';

    void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(MyApp());
    }


    class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
    primarySwatch: Colors.blue,
    ),
    home: SignInRegisterPage(),
    );
    }
    }

    class SignInRegisterPage extends StatefulWidget {
    @override
    _SignInRegisterPageState createState() => _SignInRegisterPageState();
    }

    class _SignInRegisterPageState extends State<SignInRegisterPage> {
    bool showSignIn = true;

    // Controllers for sign in
    final _signInEmailController = TextEditingController();
    final _signInPasswordController = TextEditingController();

    // Controllers for register
    final _registerEmailController = TextEditingController();
    final _registerPasswordController = TextEditingController();
    final _titleController = TextEditingController();
    final _firstNameController = TextEditingController();
    final _lastNameController = TextEditingController();
    final _dobController = TextEditingController(); // Date of Birth
    final _countryController = TextEditingController();

    // Checkbox state
    bool _agreeTerms = false;

    @override
    void dispose() {
    // Dispose all the controllers
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _titleController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    super.dispose();
    }

    void _toggleForm() {
    setState(() {
    showSignIn = !showSignIn;
    });
    }

    // future
    Future<void> _signIn() async {
    try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: _signInEmailController.text,
    password: _signInPasswordController.text,
    );
    // On successful sign-in, navigate to your home screen
    } on FirebaseAuthException catch (e) {
    // Handle the error, for example by showing a Snackbar
    }
    }

    Future<void> _register() async {
    print('Attempting to register user with email: ${_registerEmailController.text}');
    try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _registerEmailController.text,
    password: _registerPasswordController.text,
    );
    print('Registration successful for user: ${credential.user?.email}');
    // On successful registration, navigate to your home screen
    } on FirebaseAuthException catch (e) {
    print('Registration failed with error: $e');
    // Handle the error, for example by showing a Snackbar
    }
    }

    //// end future



    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Container( /// here
    alignment: Alignment.center,
    width: double.infinity,
    height: kToolbarHeight,
    color: Color(0xFFD50000),
    child: Image.asset('image2.png', fit: BoxFit.contain),
    ), // Replace with your image asset or network image
    centerTitle: true,
    actions: <Widget>[
    TextButton(
    onPressed: _toggleForm,
    child: Text(showSignIn ? 'Register' : 'Sign In', style: TextStyle(color: Colors.red)),
    ),

    ],
    backgroundColor: Colors.transparent,
    elevation: 0,
    ),
    body: Center(
    child: SingleChildScrollView(
    padding: EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    if (showSignIn) ...[
    TextFormField(
    controller: _signInEmailController,
    decoration: InputDecoration(labelText: 'Email'),
    keyboardType: TextInputType.emailAddress,
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _signInPasswordController,
    decoration: InputDecoration(labelText: 'Password'),
    obscureText: true,
    ),
    SizedBox(height: 24),
    ElevatedButton(
    onPressed: () {
    // TODO: Implement sign-in logic
    },
    child: Text('Sign In'),
    ),
    ] else ...[
    DropdownButtonFormField<String>(
    value: null,
    hint: Text('Select Title'),
    onChanged: (String? newValue) {
    // Implement title selection logic
    },
    items: <String>['Mr', 'Ms', 'Mrs', 'Dr', 'Prof']
    .map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
    );
    }).toList(),
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _firstNameController,
    decoration: InputDecoration(labelText: 'First Name'),
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _lastNameController,
    decoration: InputDecoration(labelText: 'Last Name'),
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _dobController,
    decoration: InputDecoration(labelText: 'Date of Birth (DD/MM/YYYY)'),
    keyboardType: TextInputType.datetime,
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _countryController,
    decoration: InputDecoration(labelText: 'Country of Residence'),
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _registerEmailController,
    decoration: InputDecoration(labelText: 'Email Address'),
    keyboardType: TextInputType.emailAddress,
    ),
    SizedBox(height: 8),
    TextFormField(
    controller: _registerPasswordController,
    decoration: InputDecoration(labelText: 'Password'),
    obscureText: true,
    ),
    Row(
    children: <Widget>[
    Checkbox(
    value: _agreeTerms,
    onChanged: (bool? value) {
    setState(() {
    _agreeTerms = value ?? false;
    });
    },
    ),
    Expanded(
    child: GestureDetector(
    onTap: () {
    // Navigate to terms and conditions page
    },
    child: Text(
    'I agree to the Terms and Conditions and Privacy Policy',
    style: TextStyle(decoration: TextDecoration.underline),
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 24),
    ElevatedButton(
    onPressed: _agreeTerms
    ? () {
    // TODO: Implement registration logic
    }
    : null, // Disable the button if terms are not agreed
    child: Text('Register'),
    ),
    ],
    ],
    ),
    ),
    ),
    );
    }
    }**/
