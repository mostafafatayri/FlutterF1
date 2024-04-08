import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details.dart';
void main() {
  runApp(MaterialApp(
    home: F1Teams2024Page(),
  ));
}

class F1Teams2024Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 Teams 2024'),
        backgroundColor: Color(0xFFD50000),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('F1team').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No teams found'));
          }

          // Convert QuerySnapshot to List<DocumentSnapshot>
          var docsList = snapshot.data!.docs;

          // Sort the documents by 'Points' after parsing them as integers
          docsList.sort((a, b) {
            int pointsA = int.parse(a['Points'] ?? '0');
            int pointsB = int.parse(b['Points'] ?? '0');
            return pointsB.compareTo(pointsA); // Use pointsA.compareTo(pointsB) for ascending order
          });
          int index = 0;
          // Map over the sorted list to create the TeamCard widgets
          return ListView(
            children: docsList.map((doc) {
              index++;
              return TeamCard(
                teamRank: index,
                teamName: doc['TeamName'],
                teamPoints: '${doc['Points']} PTS',
                teamLogoPath: doc['TeamLogo'],
                drivers: [
                  Driver(name: doc['f1DriverOne'], imagePath: doc['driver1']),
                  Driver(name: doc['f1driverTwo'], imagePath: doc['driver2']),
                ],
              );
            }).toList(),
          );
        },
      ),


    );
  }
}

class TeamCard extends StatelessWidget {
  final int teamRank;
  final String teamName;
  final String teamPoints;
  final String teamLogoPath;
  final List<Driver> drivers;

  TeamCard({
    required this.teamRank,
    required this.teamName,
    required this.teamPoints,
    required this.teamLogoPath,
    required this.drivers,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailsPage(teamName: teamName),
            ),
          );
        },
    child: Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$teamRank | $teamName',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  teamPoints,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Image.network(  // Changed to network image
              teamLogoPath,
              height: 100,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: drivers
                  .map((driver) => Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(driver.imagePath),  // Changed to network image
                    radius: 30,
                  ),
                  Text(driver.name),
                ],
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    ));
  }
}


class Driver {
  final String name;
  final String imagePath;

  Driver({required this.name, required this.imagePath});
}


/***
 * import 'package:flutter/material.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'details.dart';
    void main() {
    runApp(MaterialApp(
    home: F1Teams2024Page(),
    ));
    }

    class F1Teams2024Page extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text('F1 Teams 2024'),
    backgroundColor: Color(0xFFD50000),
    ),
    body: StreamBuilder(
    stream: FirebaseFirestore.instance
    .collection('F1team')
    .orderBy('Points', descending: true) // Sorts the documents by 'Points' in descending order
    .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (!snapshot.hasData) {
    return Center(child: Text('No teams found'));
    }

    return ListView(
    children: snapshot.data!.docs.map((doc) {
    return TeamCard(
    teamRank: doc['rank'],
    teamName: doc['TeamName'],
    teamPoints: '${doc['Points']} PTS',//'${doc['Points']} PTS'?? '0 PTS',
    teamLogoPath: doc['TeamLogo'],
    drivers: [
    Driver(name: doc['f1DriverOne'], imagePath: doc['driver1']),
    Driver(name: doc['f1driverTwo'], imagePath: doc['driver2']),
    ],
    );
    }).toList(),
    );
    },
    ),
    );
    }
    }

    class TeamCard extends StatelessWidget {
    final String teamRank;
    final String teamName;
    final String teamPoints;
    final String teamLogoPath;
    final List<Driver> drivers;

    TeamCard({
    required this.teamRank,
    required this.teamName,
    required this.teamPoints,
    required this.teamLogoPath,
    required this.drivers,
    });

    @override
    Widget build(BuildContext context) {
    return InkWell(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => TeamDetailsPage(teamName: teamName),
    ),
    );
    },
    child: Card(
    margin: EdgeInsets.all(10.0),
    child: Padding(
    padding: EdgeInsets.all(8.0),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    '$teamRank | $teamName',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    Text(
    teamPoints,
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    ],
    ),
    SizedBox(height: 10),
    Image.network(  // Changed to network image
    teamLogoPath,
    height: 100,
    width: double.infinity,
    fit: BoxFit.contain,
    ),
    Divider(),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: drivers
    .map((driver) => Column(
    children: [
    CircleAvatar(
    backgroundImage: NetworkImage(driver.imagePath),  // Changed to network image
    radius: 30,
    ),
    Text(driver.name),
    ],
    ))
    .toList(),
    ),
    ],
    ),
    ),
    ));
    }
    }


    class Driver {
    final String name;
    final String imagePath;

    Driver({required this.name, required this.imagePath});
    }




 */