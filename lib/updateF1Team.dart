import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamEditPage extends StatefulWidget {
  @override
  _TeamEditPageState createState() => _TeamEditPageState();
}

class _TeamEditPageState extends State<TeamEditPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeamId;
  List<DropdownMenuItem<String>> _teamDropdownItems = [];
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {
      'name': TextEditingController(),
      'base': TextEditingController(),
      'teamChief': TextEditingController(),
      'techChief': TextEditingController(),
      'chassis': TextEditingController(),
      'powerUnit': TextEditingController(),
      'firstEntry': TextEditingController(),
      'worldChampions': TextEditingController(),
      'highestRaceFinish': TextEditingController(),
       //
      'highestRaceFinish(X)': TextEditingController(),
      //
      'polePositions': TextEditingController(),
      'fastestLaps': TextEditingController(),
    };
  }

  Future<void> _fetchTeams() async {
    var teamsQuerySnapshot = await FirebaseFirestore.instance.collection('F1team').get();
    var fetchedItems = teamsQuerySnapshot.docs.map((doc) {
      return DropdownMenuItem<String>(
        value: doc.id,
        child: Text(doc['TeamName']),
      );
    }).toList();

    setState(() {
      _teamDropdownItems = fetchedItems;
    });
  }

  void _loadTeamDetails(String teamId) async {
    var teamSnapshot = await FirebaseFirestore.instance.collection('F1team').doc(teamId).get();
    var teamData = teamSnapshot.data();

    // Fetch the corresponding team details from teamsDetails collection                            /// teamData?['TeamName']
    var teamDetailsSnapshot = await FirebaseFirestore.instance.collection('teamsDetails').where('refID', isEqualTo: teamId ).limit(1).get();
    var teamDetailsData = teamDetailsSnapshot.docs.first.data();


    if (teamData != null) {
      // Assuming 'TeamName' is the field in the document
      _controllers['name']!.text = teamData['TeamName'];
      //_controllers['TeamID']!.text = teamData[''];


    }

    setState(() {

      _controllers['base']!.text = teamDetailsData?['Base'] ?? '';
      _controllers['teamChief']!.text = teamDetailsData?['TeamChief'] ?? '';
      _controllers['techChief']!.text = teamDetailsData?['TechChief'] ?? '';
      _controllers['chassis']!.text = teamDetailsData?['Chassis'] ?? '';
      _controllers['powerUnit']!.text = teamDetailsData?['Power Unit'] ?? '';
      _controllers['firstEntry']!.text = teamDetailsData?['FirstEntry'] ?? '';
      _controllers['worldChampions']!.text = teamDetailsData?['WC'] ?? '';
      _controllers['highestRaceFinish']!.text = teamDetailsData?['HighestRaceFinish'] ?? '';
      _controllers['highestRaceFinish(X)']!.text = teamDetailsData?['HighestRaceFinish(X)'] ?? '';
      _controllers['polePositions']!.text = teamDetailsData?['Pole'] ?? '';
      _controllers['fastestLaps']!.text = teamDetailsData?['FastestLaps'] ?? '';
    });
  }

  void _saveTeamDetails() async {
    if (_formKey.currentState!.validate()) {
      try{
        Map<String, dynamic> f1teamData = {
         'TeamName':_controllers['name']!.text
        };
      Map<String, dynamic> updatedData = {
        'Name':_controllers['name']!.text,
        'Base': _controllers['base']!.text,
        'TeamChief': _controllers['teamChief']!.text,
        'TechChief': _controllers['techChief']!.text,
        'Chassis': _controllers['chassis']!.text,
        'Power Unit': _controllers['powerUnit']!.text,
        'FirstEntry': _controllers['firstEntry']!.text,
        'WC': _controllers['worldChampions']!.text,
        'HighestRaceFinish': _controllers['highestRaceFinish']!.text,
        'HighestRaceFinish(X)':_controllers['highestRaceFinish(X)']!.text,
        'Pole': _controllers['polePositions']!.text,
        'FastestLaps': _controllers['fastestLaps']!.text,
      };

      print("the id id : $_selectedTeamId");
      // Update in F1team collection
      await FirebaseFirestore.instance.collection('F1team').doc(_selectedTeamId).update(f1teamData);

      // Update in teamsDetails collection as well
        String teamName = _controllers['name']!.text;
      var teamDetailsDoc = await FirebaseFirestore.instance.collection('teamsDetails').where('Name', isEqualTo: teamName).limit(1).get();
      if (teamDetailsDoc.docs.isNotEmpty) {
        await teamDetailsDoc.docs.first.reference.update(updatedData);
      }
      if (_selectedTeamId != null) {
       // await FirebaseFirestore.instance.collection('F1team').doc(_selectedTeamId).update(updatedData);

        // Update the corresponding team details in teamsDetails collection
       String teamName = _controllers['name']!.text;
        var teamDetailsQuerySnapshot = await FirebaseFirestore.instance.collection('teamsDetails')
            .where('Name', isEqualTo: teamName)
            .limit(1)
            .get();


        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team details updated successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a team.')));
      }

      }catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update team details: $e')));
      }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Team Details')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedTeamId,
                  items: _teamDropdownItems,
                  onChanged: (value) {
                    if (value != null) {
                      _selectedTeamId = value;
                      _loadTeamDetails(value);
                    }
                  },
                  decoration: InputDecoration(labelText: 'Select Team'),
                ),
                ..._controllers.entries.map((entry) {
                  return TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(labelText: entry.key),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ${entry.key}';
                      }
                      return null;
                    },
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTeamDetails,
                  child: Text('Save Changes'),
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
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
