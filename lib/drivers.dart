import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    home: F1DriversPage(),
  ));
}

class F1DriversPage extends StatelessWidget {
  Future<List<DriverInfo>> getDrivers() async {
    var driversQuery = await FirebaseFirestore.instance
        .collection('Drivers')
        .orderBy('Points', descending: true)
        .get();

    List<DriverInfo> drivers = [];
    int rank = 1; // Initialize driver rank

    for (var driverDoc in driversQuery.docs) {
      var driverData = driverDoc.data();
      String driverName = driverData['Name'];
      String driverNumber = driverData['Number'].toString();

      var teamQuery = await FirebaseFirestore.instance
          .collection('F1team')
          .where('f1DriverOne', isEqualTo: driverName)
          .limit(1)
          .get();

      if (teamQuery.docs.isEmpty) {
        teamQuery = await FirebaseFirestore.instance
            .collection('F1team')
            .where('f1driverTwo', isEqualTo: driverName)
            .limit(1)
            .get();
      }

      String teamName = '';
      String driverImageUrl = '';

      if (teamQuery.docs.isNotEmpty) {
        var teamData = teamQuery.docs.first.data();
        teamName = teamData['TeamName'];
        driverImageUrl = driverName == teamData['f1DriverOne'] ? teamData['driver1'] : teamData['driver2'];
      }

      drivers.add(DriverInfo(
        name: driverName,
        points: driverData['Points'].toString(),
        teamName: teamName,
        imageUrl: driverImageUrl,
        number: driverNumber,
        rank: 'P$rank', // Assign the rank as "P1", "P2", etc.
      ));

      rank++; // Increment rank for the next driver
    }

    return drivers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 Drivers 2024'),
        backgroundColor: Color(0xFFD50000),
      ),
      body: FutureBuilder<List<DriverInfo>>(
        future: getDrivers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No drivers found'));
          } else {
            return GridView.count(
              crossAxisCount: 2,
              children: snapshot.data!.map((driverInfo) {
                return DriverCard(
                  position: driverInfo.rank,
                  driverName: driverInfo.name,
                  teamName: driverInfo.teamName,
                  points: '${driverInfo.points} PTS',
                  driverImageUrl: driverInfo.imageUrl,
                  driverNumber: driverInfo.number,
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final String position;
  final String driverName;
  final String teamName;
  final String points;
  final String driverImageUrl;
  final String driverNumber;

  const DriverCard({
    Key? key,
    required this.position,
    required this.driverName,
    required this.teamName,
    required this.points,
    required this.driverImageUrl,
    required this.driverNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(driverImageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$position | $driverName #$driverNumber',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  teamName,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  '$points ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DriverInfo {
  final String name;
  final String points;
  final String teamName;
  final String imageUrl;
  final String number;
  final String rank;

  DriverInfo({
    required this.name,
    required this.points,
    required this.teamName,
    required this.imageUrl,
    required this.number,
    required this.rank,
  });
}


/**
 * import 'package:flutter/material.dart';

    void main() {
    runApp(MyApp());
    }

    class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Formula 1 Drivers 2024',
    theme: ThemeData(
    primarySwatch: Colors.red,
    ),
    debugShowCheckedModeBanner: false,
    home: F1DriversPage(),
    );
    }
    }

    class F1DriversPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text('F1 Drivers 2024'),
    backgroundColor: Color(0xFFD50000),
    ),
    body: GridView.count(
    crossAxisCount: 2,
    children: List.generate(20, (index) {
    // Generate 20 placeholder cards
    return DriverCard(
    position: index + 1,
    driverName: 'Driver ${index + 1}',
    teamName: 'Team ${index % 5}', // Just for varied placeholders
    points: '${50 - index}', // Placeholder for points
    driverImageUrl: 'lclerc.png',//'assets/drivers/driver_${index + 1}.png', // Placeholder image asset
    );
    }),
    ),
    );
    }
    }

    class DriverCard extends StatelessWidget {
    final int position;
    final String driverName;
    final String teamName;
    final String points;
    final String driverImageUrl;

    const DriverCard({
    Key? key,
    required this.position,
    required this.driverName,
    required this.teamName,
    required this.points,
    required this.driverImageUrl,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
    return Card(
    elevation: 4,
    margin: EdgeInsets.all(10),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
    Expanded(
    child: Image.asset(
    driverImageUrl,
    fit: BoxFit.cover,
    ),
    ),
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    '$position | $driverName',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    Text(
    teamName,
    style: TextStyle(
    fontSize: 16,
    color: Colors.grey,
    ),
    ),
    Text(
    '$points PTS',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    );
    }
    }

 */