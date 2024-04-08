import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import  'addTrack.dart';
import 'updateF1Team.dart';
import 'AddBlogs.dart';

void main() {
  runApp(MaterialApp(home: AddF1TeamPage()));
}

class AddF1TeamPage extends StatefulWidget {
  @override
  _AddF1TeamPageState createState() => _AddF1TeamPageState();
}

class _AddF1TeamPageState extends State<AddF1TeamPage> {
  final _formKey = GlobalKey<FormState>();
  final teamNameController = TextEditingController();
  final teamRankController = TextEditingController();
  final teamPointsController = TextEditingController();
  final driverOneNameController = TextEditingController();
  final driverTwoNameController = TextEditingController();

  Uint8List? _teamLogo;
  Uint8List? _driverOneImage;
  Uint8List? _driverTwoImage;

  Future<void> pickImageAndSetState(ImageSource source, void Function(Uint8List?) setStateCallback) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        setStateCallback(imageData);
      });
    }
  }

  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      print("testing $storageRef upload  ");
      await uploadTask;

      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      throw e;  // Re-throw the error after logging it
    }
  }

  void addTeam() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Adding team...'), duration: Duration(seconds: 2)));
      try {
        String teamLogoFileName = 'teamLogo_${DateTime.now().millisecondsSinceEpoch}.png';
        String teamLogoUrl = await uploadImage(_teamLogo!, teamLogoFileName);

        // for the drivers
        String driverOneFileName = 'driverOne_${DateTime.now().millisecondsSinceEpoch}.png';
        String driverOneImageUrl = await uploadImage(_driverOneImage!, driverOneFileName);

        // Upload the driver two image
        String driverTwoFileName = 'driverTwo_${DateTime.now().millisecondsSinceEpoch}.png';
        String driverTwoImageUrl = await uploadImage(_driverTwoImage!, driverTwoFileName);


        ////
        DocumentReference teamDocRef = await FirebaseFirestore.instance.collection('F1team').add({
          'TeamName': teamNameController.text,
          'rank': teamRankController.text,
          'Points': teamPointsController.text,
          'TeamLogo': teamLogoUrl,  // Use the uploaded image URL
          'f1DriverOne': driverOneNameController.text,
          'f1driverTwo': driverTwoNameController.text,
          'driver1': driverOneImageUrl,
          'driver2': driverTwoImageUrl,
        });

        String newTeamId = teamDocRef.id;


        await FirebaseFirestore.instance.collection('teamsDetails').add({
          'Name':teamNameController.text,
          'refID':newTeamId
        });

        await FirebaseFirestore.instance.collection("Drivers").add({
          'Name':driverOneNameController.text,
          'Points':0,
          'Number':0,
          'refID':newTeamId
        });
        await FirebaseFirestore.instance.collection("Drivers").add({
          'Name':driverTwoNameController.text,
          'Points':0,
          'Number':0,
          'refID':newTeamId
        });




        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team added successfully!'), duration: Duration(seconds: 2)));

        print("Team Added");
        _formKey.currentState!.reset();
        setState(() {
          _teamLogo = null;
          _driverOneImage = null;
          _driverTwoImage = null;
        });

      } catch (e) {
        print('An error occurred while adding the team: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add team: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New F1 Team'),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: teamNameController,
                  decoration: InputDecoration(labelText: 'Team Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the team name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: teamRankController,
                  decoration: InputDecoration(labelText: 'Team Rank'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the team rank';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: teamPointsController,
                  decoration: InputDecoration(labelText: 'Team Points'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the team points';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: driverOneNameController,
                  decoration: InputDecoration(labelText: 'Driver 1 Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of Driver 1';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: driverTwoNameController,
                  decoration: InputDecoration(labelText: 'Driver 2 Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of Driver 2';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => pickImageAndSetState(ImageSource.gallery, (img) => _teamLogo = img),
                  child: Text('Choose Team Logo'),
                ),
                ElevatedButton(
                  onPressed: () => pickImageAndSetState(ImageSource.gallery, (img) => _driverOneImage = img),
                  child: Text('Upload Driver 1 Image'),
                ),
                ElevatedButton(
                  onPressed: () => pickImageAndSetState(ImageSource.gallery, (img) => _driverTwoImage = img),
                  child: Text('Upload Driver 2 Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addTeam,
                  child: Text('Add Team'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    // Navigate to the AddTrackPage when the button is pressed
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TeamEditPage()),
                    );
                  },
                  child: Text('Update An  Team'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                ),


                SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Drivers').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return Text('No drivers found');
                    }

                    List<DataRow> rows = snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      TextEditingController nameController = TextEditingController(text: data['Name']);
                      TextEditingController pointsController = TextEditingController(text: data['Points'].toString());
                      TextEditingController NumberController = TextEditingController(text: data['Number'].toString());

                      return DataRow(cells: [
                        DataCell(TextField(controller: nameController)),
                        DataCell(TextField(controller: pointsController)),
                        DataCell(TextField(controller: NumberController)),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () async {
                              int newPoints = int.tryParse(pointsController.text) ?? 0;
                              int newNumber = int.tryParse(NumberController.text) ?? 0;

                              // Update the current document first
                              await document.reference.update({
                                'Name': nameController.text,
                                'Points': newPoints,
                                'Number': newNumber,
                              });

                              // Get the 'F1team' document by reference ID
                              DocumentReference f1teamDocRef = FirebaseFirestore.instance.collection('F1team').doc(data['refID'].toString());

                              FirebaseFirestore.instance.runTransaction((transaction) async {
                                DocumentSnapshot f1teamSnapshot = await transaction.get(f1teamDocRef);

                                if (!f1teamSnapshot.exists) {
                                  throw Exception("F1team document does not exist!");
                                }

                                var f1teamData = f1teamSnapshot.data();
                                if (f1teamData is Map<String, dynamic>) {
                                  var currentPointsValue = f1teamData['Points'];
                                  int currentPoints = 0;

                                  // Check if the points value is a string and if so, parse it to int
                                  if (currentPointsValue is String) {
                                    currentPoints = int.tryParse(currentPointsValue) ?? 0;
                                  } else if (currentPointsValue is int) {
                                    // If it's already an int, use it directly
                                    currentPoints = currentPointsValue;
                                  }

                                  int updatedPoints = currentPoints + newPoints;

                                  // Perform the update
                                  transaction.update(f1teamDocRef, {
                                    'Points': updatedPoints.toString(), // Make sure to save it as a string if that's what your database expects
                                  });
                                } else {
                                  throw Exception("Invalid data structure for F1team document");
                                }
                              }).then((value) {
                                print('F1team document updated');
                              }).catchError((error) {
                                print('Failed to update F1team document: $error');
                              });
                            },
                          ),



                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              document.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver Deleted successfully!')));
                            },
                          ),
                        ),
                      ]);
                    }).toList();

                    return DataTable(columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Points')),
                      DataColumn(label: Text('Number')),
                      DataColumn(label: Text('Save')),
                      DataColumn(label: Text('Delete')),
                    ], rows: rows);


                  },
                ),
                SizedBox(height: 20), // Optional space for better UI

// Here is where you add the ElevatedButton
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the AddTrackPage when the button is pressed
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AddTrackPage()),
                    );
                  },
                  child: Text('Add New Track'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900], // Set the background color of the button
                    //onPrimary: Colors.white, // Set the text color of the button
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the AddTrackPage when the button is pressed
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => BlogPostCreator()),
                    );
                  },
                  child: Text('Add new blog'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900], // Set the background color of the button
                    //onPrimary: Colors.white, // Set the text color of the button
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }



  @override
  void dispose() {
    teamNameController.dispose();
    teamRankController.dispose();
    teamPointsController.dispose();
    driverOneNameController.dispose();
    driverTwoNameController.dispose();
    super.dispose();
  }
}

/**
 * import 'dart:typed_data';
    import 'package:flutter/material.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:image_picker/image_picker.dart';

    void main() {
    runApp(MaterialApp(home: AddF1TeamPage()));
    }

    class AddF1TeamPage extends StatefulWidget {
    @override
    _AddF1TeamPageState createState() => _AddF1TeamPageState();
    }

    class _AddF1TeamPageState extends State<AddF1TeamPage> {
    final _formKey = GlobalKey<FormState>();
    final teamNameController = TextEditingController();
    final teamRankController = TextEditingController();
    final teamPointsController = TextEditingController();
    final driverOneNameController = TextEditingController();
    final driverTwoNameController = TextEditingController();

    Uint8List? _teamLogo;
    Uint8List? _driverOneImage;
    Uint8List? _driverTwoImage;

    Future<void> pickImageAndSetState(ImageSource source, void Function(Uint8List?) setStateCallback) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
    final Uint8List imageData = await image.readAsBytes();
    setState(() {
    setStateCallback(imageData);
    });
    }
    }

    Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    print("testing $storageRef upload  ");
    await uploadTask;

    return await storageRef.getDownloadURL();
    } catch (e) {
    print('Failed to upload image: $e');
    throw e;  // Re-throw the error after logging it
    }
    }

    void addTeam() async {
    if (_formKey.currentState!.validate()) {
    try {
    String teamLogoFileName = 'teamLogo_${DateTime.now().millisecondsSinceEpoch}.png';
    String teamLogoUrl = await uploadImage(_teamLogo!, teamLogoFileName);

    await FirebaseFirestore.instance.collection('F1team').add({
    'TeamName': teamNameController.text,
    'rank': teamRankController.text,
    'Points': teamPointsController.text,
    'TeamLogo': teamLogoUrl,  // Use the uploaded image URL
    'f1DriverOne': driverOneNameController.text,
    'f1driverTwo': driverTwoNameController.text,
    });

    print("Team Added");
    _formKey.currentState!.reset();
    } catch (e) {
    print('An error occurred while adding the team: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add team: $e')));
    }
    } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.')));
    }
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text('Add New F1 Team'),
    backgroundColor: Colors.red[900],
    ),
    body: SingleChildScrollView(
    child: Form(
    key: _formKey,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    // Your TextFormFields and other Widgets
    ElevatedButton(
    onPressed: () => pickImageAndSetState(ImageSource.gallery, (img) => _teamLogo = img),
    child: Text('Choose Team Logo'),
    ),
    ElevatedButton(
    onPressed: () => pickImageAndSetState(ImageSource.gallery, (img) => _driverOneImage = img),
    child: Text('Upload Driver 1 Image'),
    ),
    ElevatedButton(
    onPressed: () => pickImageAndSetState(ImageSource.gallery, (img) => _driverTwoImage = img),
    child: Text('Upload Driver 2 Image'),
    ),
    ElevatedButton(
    onPressed: addTeam,
    child: Text('Add Team'),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
    ),
    ],
    ),
    ),
    ),
    ),
    );
    }



    @override
    void dispose() {
    teamNameController.dispose();
    teamRankController.dispose();
    teamPointsController.dispose();
    driverOneNameController.dispose();
    driverTwoNameController.dispose();
    super.dispose();
    }
    }

 */