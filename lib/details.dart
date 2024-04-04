import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    title: 'Red Bull Racing Team',
    theme: ThemeData(
      primarySwatch: Colors.red,
    ),
    home: TeamDetailsPage(teamName: 'Some Team Name')
    ,
  ));
}
///

class TeamDetailsPage extends StatelessWidget {
  // here
  final String teamName;

  TeamDetailsPage({this.teamName = 'Default Team Name'});

  Future<Map<String, dynamic>> getTeamDetails() async {
    // Get team details from 'F1team' collection
    var teamQuery = await FirebaseFirestore.instance
        .collection('F1team')
        .where('TeamName', isEqualTo: teamName)
        .limit(1)
        .get();

    if (teamQuery.docs.isEmpty) {
      throw Exception("Team not found");
    }
    var teamData = teamQuery.docs.first.data();

    // Get drivers' numbers from 'Drivers' collection
    var driverOneQuery = await FirebaseFirestore.instance
        .collection('Drivers')
        .where('Name', isEqualTo: teamData['f1DriverOne'])
        .limit(1)
        .get();

    var driverTwoQuery = await FirebaseFirestore.instance
        .collection('Drivers')
        .where('Name', isEqualTo: teamData['f1driverTwo'])
        .limit(1)
        .get();

    var detailsQuery = await FirebaseFirestore.instance
        .collection('teamsDetails')
        .where('Name', isEqualTo: teamName)
        .limit(1)
        .get();

    Map<String, dynamic> detailsData = detailsQuery.docs.isNotEmpty ? detailsQuery.docs.first.data() : {};



    // Combine data
    Map<String, dynamic> combinedData = {
      'teamDetails': teamData,
      'details': detailsQuery.docs.isNotEmpty ? detailsQuery.docs.first.data() : {},
      'driverOneDetails': driverOneQuery.docs.isNotEmpty ? driverOneQuery.docs.first.data() : null,
      'driverTwoDetails': driverTwoQuery.docs.isNotEmpty ? driverTwoQuery.docs.first.data() : null
    };

    return combinedData;
  }

  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(teamName),
          backgroundColor: Colors.red,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
        future: getTeamDetails(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.hasError) {
    return Center(child: Text("Error loading team details"));
    }

    var teamDetails = snapshot.data!['teamDetails'];
    var driverOneDetails = snapshot.data!['driverOneDetails'];
    var driverTwoDetails = snapshot.data!['driverTwoDetails'];
    var teamsDetails = snapshot.data!['details'];


    print("the details : $teamsDetails");

    print("${teamDetails} data");
    return SingleChildScrollView(
    child: Column(
    children: [
    Image.network(
    teamDetails['TeamLogo'],
    width: double.infinity,
    height: MediaQuery.of(context).size.height * 0.3,
    fit: BoxFit.fitWidth,
    ),
    Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    teamDetails['TeamName'],
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    ),
    ),
                  Text('Base: ${teamsDetails['Base'] ?? 'N/A'}'),
                  Text('Team Chief: ${teamsDetails['TeamChief'] ?? 'N/A'}'),
                  Text('Technical Chief: ${teamsDetails['TechChief'] ?? 'N/A'}'),
                  Text('Chassis: ${teamsDetails['Chassis'] ?? 'N/A'}'),
                  Text('Power Unit: ${teamsDetails['Power Unit'] ?? 'N/A'}'),
                  Text('First Entry: ${teamsDetails['FirstEntry'] ?? 'N/A'}'),
                  Text('World Champions: ${teamsDetails['WC'] ?? 'N/A'}'),

                 Text('Highest Race Finish: ${teamsDetails['HighestRaceFinish']} (X${teamsDetails['HighestRaceFinish(X)'] ?? 'N/A'})'),
                  Text('Pole  Positions: ${teamsDetails['Pole'] ?? 'N/A'}'),
                  Text('Fastest Laps: ${teamsDetails['FastestLaps'] ?? 'N/A'}'),

                  // ... Add other details
      SizedBox(height: 20),
      Text(
        'Drivers',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DriverCard(
            driverNumber: driverOneDetails['Number'].toString(),
            driverName: teamDetails['f1DriverOne'],
            driverImagePath: teamDetails['driver1'],
          ),
          DriverCard(
            driverNumber: driverTwoDetails['Number'].toString(),
            driverName: teamDetails['f1driverTwo'],
            driverImagePath: teamDetails['driver2'],
          ),
        ],
      ),
    ],
    ),
    ),
    ],
    ),
    );
    },
        ),
    );
  }
}




class TeamInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use a Table for structured layout
    return Table(
      children: [
        TableRow(
          children: [
            Text('Full Team Name', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Oracle Red Bull Racing'),
          ],
        ),
        TableRow(children: [
          Text('Base', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Milton Keynes, United Kingdom'),
        ]),
        // Add other rows for Team Chief, Technical Chief, etc.
      ],
    );
  }
}

class DriverCard extends StatelessWidget {
  final String driverNumber;
  final String driverName;
  final String driverImagePath;

  const DriverCard({
    required this.driverNumber,
    required this.driverName,
    required this.driverImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          driverImagePath,
          width: 140,
          height: MediaQuery.of(context).size.height * 0.2,
          fit: BoxFit.cover,
        ),
        Text(
          'No. $driverNumber',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          driverName,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}


/*import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Red Bull Racing Team',
    theme: ThemeData(
      primarySwatch: Colors.red,
    ),
    home: TeamDetailsPage(),
  ));
}

class TeamDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Red Bull Racing Team'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'redbull.png', // Replace with your network image URL
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oracle Red Bull Racing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text('Base: Milton Keynes, United Kingdom'),
                  Text('Team Chief: Christian Horner'),
                  Text('Technical Chief: Pierre Waché'),

                  Text('Chassis: RB20'),
                  Text('Power Unit: Honda RBPT'),
                  Text('First Entry: 1997'),
                  Text('World Champions: 6'),
                  Text('Highest Race Finish: 1(x115)'),
                  Text('Pole  Positions: 98'),
                  Text('Fastest Laps: 96'),

                  // ... Add other details
                  SizedBox(height: 20),
                  Text(
                    'Drivers',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  DriverTile(
                    number: '1',
                    name: 'Max Verstappen',
                    imagePath: 'redbull.png', // Replace with your image path
                  ),
                  DriverTile(
                    number: '11',
                    name: 'Sergio Perez',
                    imagePath: 'redbull.png', // Replace with your image path
                  ),
                  // ... Add other drivers
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverTile extends StatelessWidget {
  final String number;
  final String name;
  final String imagePath;

  const DriverTile({
    Key? key,
    required this.number,
    required this.name,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath), // For a network image, use NetworkImage(imagePath)
        radius: 30,
      ),
      title: Text(name, style: TextStyle(fontSize: 16)),
      subtitle: Text('Team Red Bull Racing', style: TextStyle(fontSize: 14, color: Colors.grey)),
      trailing: Text('No. $number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
*/