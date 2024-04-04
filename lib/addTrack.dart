import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart'; // Add intl package to format dates

void main() {
  runApp(MaterialApp(home: AddTrackPage()));
}

class AddTrackPage extends StatefulWidget {
  @override
  _AddTrackPageState createState() => _AddTrackPageState();
}

class _AddTrackPageState extends State<AddTrackPage> {
  final _formKey = GlobalKey<FormState>();
  final Country = TextEditingController(); ///
  final TrackName = TextEditingController();
  final firstGPController = TextEditingController();
  final numberOfLapsController = TextEditingController();
  final circuitLengthController = TextEditingController();
  final raceDistanceController = TextEditingController();
  final lapRecordController = TextEditingController();
  final raceTitleController = TextEditingController();
  // here
  Map<String, TimeOfDay?> _times = {
    'FP1': null,
    'FP2': null,
    'FP3': null,
    'Qualifying': null,
    'Race': null,
  };
  Future<void> _selectTime(BuildContext context, String key) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _times[key]) {
      setState(() {
        _times[key] = pickedTime;
      });
    }
  }

  //here to map:
  Uint8List? _circuitMapImage; // Add a new field for the circuit map image

  // ... Your existing methods

  // Add a new method for picking the circuit map image



  Future<void> pickMapImageAndSetState() async {
    final imageData = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      _circuitMapImage = imageData;
    });
  }



  //

  Uint8List? _circuitImage;
  String? _selectedTrack;
  List<DropdownMenuItem<String>> _dropdownMenuItems = [];
  DateTimeRange? _dateRange;
  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }
  Future<void> _fetchTracks() async {
    var tracksSnapshot = await FirebaseFirestore.instance.collection('Tracks').get();
    var tracksItems = tracksSnapshot.docs.map((doc) {
      return DropdownMenuItem<String>(
        value: doc.id, // Use the document ID as the value
        child: Text(doc['Name']), // Use the track name as the label
      );
    }).toList();

    setState(() {
      _dropdownMenuItems = tracksItems;
    });
  }
  Future<void> pickImageAndSetState() async {
    final imageData = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      _circuitImage = imageData;
    });
  }

  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    Reference storageRef = FirebaseStorage.instance.ref().child('circuit_images/$fileName');
    UploadTask uploadTask = storageRef.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
  final _trackFormKey = GlobalKey<FormState>(); // New key for track form
  final _raceScheduleFormKey = GlobalKey<FormState>(); // New key for race schedule form

  void addTrack() async {
    print("the button is pressed: \n");
    if (_trackFormKey.currentState!.validate() && _circuitImage != null )//&& _circuitMapImage != null) {
     { print("entered the if sattet");
      try {

        String circuitImageFileName = 'circuit_${DateTime.now().millisecondsSinceEpoch}.png';
        String circuitImageUrl = await uploadImage(_circuitImage!, circuitImageFileName);
        print("the url : $circuitImageUrl");

        String circuitMapImageFileName = 'circuit_map_${DateTime.now().millisecondsSinceEpoch}.png';
        String circuitMapImageUrl = await uploadImage(_circuitMapImage!, circuitMapImageFileName);

        print("the url : $circuitMapImageUrl");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Adding track !')));
        await FirebaseFirestore.instance.collection('Tracks').add({
          'FirstGP': firstGPController.text,
          'Country': Country.text,
          'Name': TrackName.text,
          'NumberOfLaps': int.parse(numberOfLapsController.text),
          'CircuitLength': double.parse(circuitLengthController.text),
          'RaceDistance': double.parse(raceDistanceController.text),
          'LapRecord': lapRecordController.text,
          'CircuitImage': circuitImageUrl,
          'CircuitMapImage':circuitMapImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Track added successfully!')));
        _formKey.currentState!.reset();
        setState(() {
          _circuitImage = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add track: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and pick an image.')));
    }
  }

  void _addRaceSchedule() async {
    // Validation logic here, including checks for _dateRange
    if (_raceScheduleFormKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Calendar').add({
          'Track': _selectedTrack,
          'StartDate': DateFormat('yyyy-MM-dd').format(_dateRange!.start),
          'EndDate': DateFormat('yyyy-MM-dd').format(_dateRange!.end),
          'Title': raceTitleController.text,
          'FP1': _times['FP1'] != null ? _times['FP1']!.format(context) : '',
          'FP2': _times['FP2'] != null ? _times['FP2']!.format(context) : '',
          'FP3': _times['FP3'] != null ? _times['FP3']!.format(context) : '',
          'Qualifying': _times['Qualifying'] != null ? _times['Qualifying']!.format(context) : '',
          'Race': _times['Race'] != null ? _times['Race']!.format(context) : '',

        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event  added successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
      }
    } else {
      // Prompt the user to pick a track and date range...
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Track'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _trackFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: Country, ///
                      decoration: InputDecoration(labelText: 'Country'),
                      validator: (value) => value!.isEmpty ? 'Please enter the Country' : null,
                    ),
                    TextFormField(
                      controller: TrackName, ///
                      decoration: InputDecoration(labelText: 'Track Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter the TrackName' : null,
                    ),
                    TextFormField(
                      controller: firstGPController,
                      decoration: InputDecoration(labelText: 'First GP'),
                      validator: (value) => value!.isEmpty ? 'Please enter the first GP year' : null,
                    ),
                    TextFormField(
                      controller: numberOfLapsController,
                      decoration: InputDecoration(labelText: 'Number of Laps'),
                      validator: (value) => value!.isEmpty ? 'Please enter the number of laps' : null,
                    ),
                    TextFormField(
                      controller: circuitLengthController,
                      decoration: InputDecoration(labelText: 'Circuit Length (km)'),
                      validator: (value) => value!.isEmpty ? 'Please enter the circuit length' : null,
                    ),
                    TextFormField(
                      controller: raceDistanceController,
                      decoration: InputDecoration(labelText: 'Race Distance (km)'),
                      validator: (value) => value!.isEmpty ? 'Please enter the race distance' : null,
                    ),
                    TextFormField(
                      controller: lapRecordController,
                      decoration: InputDecoration(labelText: 'Lap Record'),
                      validator: (value) => value!.isEmpty ? 'Please enter the lap record' : null,
                    ),
                    SizedBox(height: 20),
                    _circuitImage != null
                        ? Image.memory(_circuitImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
                        : ElevatedButton(
                      onPressed: pickImageAndSetState,
                      child: Text('Choose Circuit Image'),
                    ),
                    _circuitMapImage != null
                        ? Image.memory(_circuitMapImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
                        : ElevatedButton(
                      onPressed: pickMapImageAndSetState,
                      child: Text('Choose Circuit Map Image'),
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addTrack,
                      child: Text('Add Track'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                    ),
                  ],
                ),
              ),
            ),
// here
            SizedBox(height: 20),
            Form(
              key: _raceScheduleFormKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedTrack,
                      items: _dropdownMenuItems,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTrack = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Select Track'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        DateTimeRange? newDateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (newDateRange != null) {
                          setState(() {
                            _dateRange = newDateRange;
                          });
                        }
                      },
                      child: Text('Choose Date Range'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _dateRange == null
                          ? 'No date range selected'
                          : 'From: ${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} To: ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: raceTitleController,
                      decoration: InputDecoration(labelText: 'Race Title'),
                      validator: (value) => value!.isEmpty ? 'Please enter the race title' : null,
                    ),
                    // Insert time pickers for FP1, FP2, FP3, Qualifying, Race
                    ..._times.entries.map((entry) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text('${entry.key} Time:'),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => _selectTime(context, entry.key),
                              child: Text(
                                _times[entry.key]?.format(context) ?? 'Select Time',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addRaceSchedule,
                      child: Text('Add Race Schedule'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                    ),
                  ],
                ),
              ),
            )




          ],
        ),
      ),
    );
  }}

/**
 *import 'dart:typed_data';
    import 'package:flutter/material.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:image_picker_web/image_picker_web.dart';
    import 'package:intl/intl.dart'; // Add intl package to format dates

    void main() {
    runApp(MaterialApp(home: AddTrackPage()));
    }

    class AddTrackPage extends StatefulWidget {
    @override
    _AddTrackPageState createState() => _AddTrackPageState();
    }

    class _AddTrackPageState extends State<AddTrackPage> {
    final _formKey = GlobalKey<FormState>();
    final Country = TextEditingController(); ///
    final TrackName = TextEditingController();
    final firstGPController = TextEditingController();
    final numberOfLapsController = TextEditingController();
    final circuitLengthController = TextEditingController();
    final raceDistanceController = TextEditingController();
    final lapRecordController = TextEditingController();
    final raceTitleController = TextEditingController();
    // here
    Map<String, TimeOfDay?> _times = {
    'FP1': null,
    'FP2': null,
    'FP3': null,
    'Qualifying': null,
    'Race': null,
    };
    Future<void> _selectTime(BuildContext context, String key) async {
    final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _times[key]) {
    setState(() {
    _times[key] = pickedTime;
    });
    }
    }
    //

    Uint8List? _circuitImage;
    String? _selectedTrack;
    List<DropdownMenuItem<String>> _dropdownMenuItems = [];
    DateTimeRange? _dateRange;
    @override
    void initState() {
    super.initState();
    _fetchTracks();
    }
    Future<void> _fetchTracks() async {
    var tracksSnapshot = await FirebaseFirestore.instance.collection('Tracks').get();
    var tracksItems = tracksSnapshot.docs.map((doc) {
    return DropdownMenuItem<String>(
    value: doc.id, // Use the document ID as the value
    child: Text(doc['Name']), // Use the track name as the label
    );
    }).toList();

    setState(() {
    _dropdownMenuItems = tracksItems;
    });
    }
    Future<void> pickImageAndSetState() async {
    final imageData = await ImagePickerWeb.getImageAsBytes();
    setState(() {
    _circuitImage = imageData;
    });
    }

    Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    Reference storageRef = FirebaseStorage.instance.ref().child('circuit_images/$fileName');
    UploadTask uploadTask = storageRef.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
    }
    final _trackFormKey = GlobalKey<FormState>(); // New key for track form
    final _raceScheduleFormKey = GlobalKey<FormState>(); // New key for race schedule form

    void addTrack() async {
    if (_trackFormKey.currentState!.validate() && _circuitImage != null) {
    try {
    String circuitImageFileName = 'circuit_${DateTime.now().millisecondsSinceEpoch}.png';
    String circuitImageUrl = await uploadImage(_circuitImage!, circuitImageFileName);

    await FirebaseFirestore.instance.collection('Tracks').add({
    'FirstGP': firstGPController.text,
    'Country': Country.text,
    'Name': TrackName.text,
    'NumberOfLaps': int.parse(numberOfLapsController.text),
    'CircuitLength': double.parse(circuitLengthController.text),
    'RaceDistance': double.parse(raceDistanceController.text),
    'LapRecord': lapRecordController.text,
    'CircuitImage': circuitImageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Track added successfully!')));
    _formKey.currentState!.reset();
    setState(() {
    _circuitImage = null;
    });
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add track: $e')));
    }
    } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and pick an image.')));
    }
    }

    void _addRaceSchedule() async {
    // Validation logic here, including checks for _dateRange
    if (_raceScheduleFormKey.currentState!.validate()) {
    try {
    await FirebaseFirestore.instance.collection('Calendar').add({
    'Track': _selectedTrack,
    'StartDate': DateFormat('yyyy-MM-dd').format(_dateRange!.start),
    'EndDate': DateFormat('yyyy-MM-dd').format(_dateRange!.end),
    'Title': raceTitleController.text,
    'FP1': _times['FP1'] != null ? _times['FP1']!.format(context) : '',
    'FP2': _times['FP2'] != null ? _times['FP2']!.format(context) : '',
    'FP3': _times['FP3'] != null ? _times['FP3']!.format(context) : '',
    'Qualifying': _times['Qualifying'] != null ? _times['Qualifying']!.format(context) : '',
    'Race': _times['Race'] != null ? _times['Race']!.format(context) : '',

    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event  added successfully!')));
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
    }
    } else {
    // Prompt the user to pick a track and date range...
    }
    }


    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text('Add New Track'),
    backgroundColor: Colors.red,
    ),
    body: SingleChildScrollView(
    child: Column(
    children: [
    Form(
    key: _trackFormKey,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    TextFormField(
    controller: Country, ///
    decoration: InputDecoration(labelText: 'Country'),
    validator: (value) => value!.isEmpty ? 'Please enter the Country' : null,
    ),
    TextFormField(
    controller: TrackName, ///
    decoration: InputDecoration(labelText: 'Track Name'),
    validator: (value) => value!.isEmpty ? 'Please enter the TrackName' : null,
    ),
    TextFormField(
    controller: firstGPController,
    decoration: InputDecoration(labelText: 'First GP'),
    validator: (value) => value!.isEmpty ? 'Please enter the first GP year' : null,
    ),
    TextFormField(
    controller: numberOfLapsController,
    decoration: InputDecoration(labelText: 'Number of Laps'),
    validator: (value) => value!.isEmpty ? 'Please enter the number of laps' : null,
    ),
    TextFormField(
    controller: circuitLengthController,
    decoration: InputDecoration(labelText: 'Circuit Length (km)'),
    validator: (value) => value!.isEmpty ? 'Please enter the circuit length' : null,
    ),
    TextFormField(
    controller: raceDistanceController,
    decoration: InputDecoration(labelText: 'Race Distance (km)'),
    validator: (value) => value!.isEmpty ? 'Please enter the race distance' : null,
    ),
    TextFormField(
    controller: lapRecordController,
    decoration: InputDecoration(labelText: 'Lap Record'),
    validator: (value) => value!.isEmpty ? 'Please enter the lap record' : null,
    ),
    SizedBox(height: 20),
    _circuitImage != null
    ? Image.memory(_circuitImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
    : ElevatedButton(
    onPressed: pickImageAndSetState,
    child: Text('Choose Circuit Image'),
    ),
    SizedBox(height: 20),
    ElevatedButton(
    onPressed: addTrack,
    child: Text('Add Track'),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
    ),
    ],
    ),
    ),
    ),
    // here
    SizedBox(height: 20),
    Form(
    key: _raceScheduleFormKey,
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    DropdownButtonFormField<String>(
    value: _selectedTrack,
    items: _dropdownMenuItems,
    onChanged: (newValue) {
    setState(() {
    _selectedTrack = newValue;
    });
    },
    decoration: InputDecoration(labelText: 'Select Track'),
    ),
    SizedBox(height: 20),
    ElevatedButton(
    onPressed: () async {
    DateTimeRange? newDateRange = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    );
    if (newDateRange != null) {
    setState(() {
    _dateRange = newDateRange;
    });
    }
    },
    child: Text('Choose Date Range'),
    ),
    SizedBox(height: 20),
    Text(
    _dateRange == null
    ? 'No date range selected'
    : 'From: ${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} To: ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
    ),
    SizedBox(height: 20),
    TextFormField(
    controller: raceTitleController,
    decoration: InputDecoration(labelText: 'Race Title'),
    validator: (value) => value!.isEmpty ? 'Please enter the race title' : null,
    ),
    // Insert time pickers for FP1, FP2, FP3, Qualifying, Race
    ..._times.entries.map((entry) {
    return Row(
    children: [
    Expanded(
    child: Text('${entry.key} Time:'),
    ),
    Expanded(
    child: TextButton(
    onPressed: () => _selectTime(context, entry.key),
    child: Text(
    _times[entry.key]?.format(context) ?? 'Select Time',
    style: TextStyle(color: Colors.black54),
    ),
    ),
    ),
    ],
    );
    }).toList(),
    SizedBox(height: 20),
    ElevatedButton(
    onPressed: _addRaceSchedule,
    child: Text('Add Race Schedule'),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
    ),
    ],
    ),
    ),
    )




    ],
    ),
    ),
    );
    }}
 */