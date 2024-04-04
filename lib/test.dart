import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Race Weekend Schedule',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: RaceWeekendPage(raceId: 'test_race_id'), // Example usage with a test ID
    );
  }
}


class RaceWeekendPage extends StatefulWidget {
  final String raceId;

  RaceWeekendPage({Key? key, required this.raceId}) : super(key: key);

  @override
  _RaceWeekendPageState createState() => _RaceWeekendPageState();
}


class _RaceWeekendPageState extends State<RaceWeekendPage> {

  // String _selectedTab = 'Schedule';
  String raceId = 'your_race_id_here'; // You need to set this to the actual race ID you're working with


  // State to keep track of the selected tab
  String _selectedTab = 'Schedule';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formula 1'),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.network(
                  'https://media.formula1.com/image/upload/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/China.jpg.transform/12col-retina/image.jpg', // Replace with the actual image URL
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'JAPAN 2024\n05 - 07 APR',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navigationButton('Schedule', Icons.schedule, () {
                    setState(() {
                      _selectedTab = 'Schedule';
                    });
                  }, _selectedTab == 'Schedule'),
                  _navigationButton('News', Icons.article, () {
                    setState(() {
                      _selectedTab = 'News';
                    });
                  }, _selectedTab == 'News'),
                  _navigationButton('Circuit', Icons.track_changes, () {
                    setState(() {
                      _selectedTab = 'Circuit';
                    });
                  }, _selectedTab == 'Circuit'),
                ],
              ),
            ),
            // Conditional rendering based on the selected tab
            if (_selectedTab == 'Schedule') RaceScheduleList(raceId: widget.raceId),
            if (_selectedTab == 'Circuit') Circuit(raceId: widget.raceId),
            // Add other conditional rendering for News, Tickets, etc...
          ],
        ),
      ),
    );
  }

  Widget _navigationButton(String title, IconData icon, VoidCallback onPressed, bool isSelected) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.red[900]),
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red[900] : Colors.white,
        //: isSelected ? Colors.white : Colors.red[900],
      ),
    );
  }
}

/*
class RaceScheduleList extends StatelessWidget {
  final String raceId;

  RaceScheduleList({Key? key, required this.raceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This could be fetched from a database in a real app
    return Column(
      children: [
        RaceScheduleCard(day: '07 APR', session: 'Race', time: '08:00'),
        RaceScheduleCard(day: '06 APR', session: 'Qualifying', time: '09:00 - 10:00'),
        RaceScheduleCard(
          day: '06 APR',
          session: 'Practice 3',
          time: '05:30 - 06:30',
        ),
        RaceScheduleCard(
          day: '05 APR',
          session: 'Practice 2',
          time: '09:00 - 10:00',
        ),
        RaceScheduleCard(
          day: '05 APR',
          session: 'Practice 1',
          time: '05:30 - 06:30',
        ),
      ],
    );
  }
}
*/






class Circuit extends StatelessWidget {
  final String raceId;

  Circuit({Key? key, required this.raceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch race details to get the track ID
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Calendar').doc(raceId).get(),
      builder: (context, raceSnapshot) {
        if (raceSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!raceSnapshot.hasData || raceSnapshot.hasError) {
          return Center(child: Text('Race details not found.'));
        }

        // Once you have the race data, extract the track ID to fetch track details
        final raceData = raceSnapshot.data!.data() as Map<String, dynamic>;
        final trackId = raceData['Track'];

        // Now fetch track details
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Tracks').doc(trackId).get(),
          builder: (context, trackSnapshot) {
            if (trackSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!trackSnapshot.hasData || trackSnapshot.hasError) {
              return Center(child: Text('Track details not found.'));
            }

            final trackData = trackSnapshot.data!.data() as Map<String, dynamic>;

            // Construct the UI with track data
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    color: Colors.grey[200], // Light grey background
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trackData["Name"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'First Grand Prix: ${trackData["FirstGP"]}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Circuit Length: ${trackData["CircuitLength"]} km',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Number of Laps: ${trackData["NumberOfLaps"]} ',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Race Distance: ${trackData["RaceDistance"]} km',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Lap Record: ${trackData["LapRecord"]}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  // Map of the circuit
                  Image.network(
                    trackData["CircuitMapImage"], // Replace with an actual map image of the circuit
                    fit: BoxFit.cover,
                  ),
                  // Additional content like onboard lap, race report, etc.
                  ListTile(
                    title: Text('Onboard Lap'),
                    leading: Icon(Icons.play_circle_fill),
                    onTap: () {
                      // TODO: Navigate to onboard lap video
                    },
                  ),
                  ListTile(
                    title: Text('2023 Race Report'),
                    leading: Icon(Icons.article),
                    onTap: () {
                      // TODO: Navigate to race report
                    },
                  ),
                  // Add more ListTile widgets for other sections
                ],
              ),
            );








          },
        );
      },
    );




  }
}


class RaceScheduleList extends StatelessWidget {
  final String raceId;

  RaceScheduleList({Key? key, required this.raceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Calendar').doc(raceId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(child: Text('Race schedule not found.'));
        } else {
          // Data is fetched successfully

          final data = snapshot.data!.data() as Map<String, dynamic>;
          String month = DateFormat('MMM').format(DateTime.parse(data['StartDate']));

          DateTime startDate = DateTime.parse(data['StartDate']);
          DateTime endDate = DateTime.parse(data['EndDate']);

          //String month = DateFormat('MMM').format(startDate);
          String startDay = DateFormat('d').format(startDate);

// Assuming the events are consecutive, calculate the next days
          String nextDay1 = DateFormat('d').format(startDate.add(Duration(days: 1)));
          String nextDay2 = DateFormat('d').format(startDate.add(Duration(days: 2)));


          List<Widget> scheduleWidgets = [
            if (data['FP1'] != null)
              RaceScheduleCard(day: '$month $startDay', session: 'Practice 1', time: data['FP1']),
            if (data['FP2'] != null)
              RaceScheduleCard(day: '$month $startDay', session: 'Practice 2', time: data['FP2']),
            if (data['FP3'] != null)
              RaceScheduleCard(day: '$month $nextDay1', session: 'Practice 3', time: data['FP3']),
            if (data['Qualifying'] != null)
              RaceScheduleCard(day: '$month $nextDay1', session: 'Qualifying', time: data['Qualifying']),
            if (data['Race'] != null)
              RaceScheduleCard(day: '$month $nextDay2', session: 'Race', time: data['Race']),



            // Repeat for FP2, FP3, Qualifying, and Race
            // ...
          ];
          return Column(
            children: scheduleWidgets,
          );
        }
      },
    );
  }
}




class RaceScheduleCard extends StatelessWidget {
  final String day;
  final String session;
  final String time;

  const RaceScheduleCard({
    Key? key,
    required this.day,
    required this.session,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
*
* import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Race Weekend Schedule',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: RaceWeekendPage(raceId: 'test_race_id'), // Example usage with a test ID
    );
  }
}


class RaceWeekendPage extends StatefulWidget {
  final String raceId;

  RaceWeekendPage({Key? key, required this.raceId}) : super(key: key);

  @override
  _RaceWeekendPageState createState() => _RaceWeekendPageState();
}


class _RaceWeekendPageState extends State<RaceWeekendPage> {

 // String _selectedTab = 'Schedule';
  String raceId = 'your_race_id_here'; // You need to set this to the actual race ID you're working with


  // State to keep track of the selected tab
  String _selectedTab = 'Schedule';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formula 1'),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.network(
                  'https://media.formula1.com/image/upload/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/China.jpg.transform/12col-retina/image.jpg', // Replace with the actual image URL
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'JAPAN 2024\n05 - 07 APR',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navigationButton('Schedule', Icons.schedule, () {
                    setState(() {
                      _selectedTab = 'Schedule';
                    });
                  }, _selectedTab == 'Schedule'),
                  _navigationButton('News', Icons.article, () {
                    setState(() {
                      _selectedTab = 'News';
                    });
                  }, _selectedTab == 'News'),
                  _navigationButton('Circuit', Icons.track_changes, () {
                    setState(() {
                      _selectedTab = 'Circuit';
                    });
                  }, _selectedTab == 'Circuit'),
                ],
              ),
            ),
            // Conditional rendering based on the selected tab
            if (_selectedTab == 'Schedule') RaceScheduleList(raceId: widget.raceId),
            if (_selectedTab == 'Circuit') Circuit(raceId: widget.raceId),
            // Add other conditional rendering for News, Tickets, etc...
          ],
        ),
      ),
    );
  }

  Widget _navigationButton(String title, IconData icon, VoidCallback onPressed, bool isSelected) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.red[900]),
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red[900] : Colors.white,
        //: isSelected ? Colors.white : Colors.red[900],
      ),
    );
  }
}

class RaceScheduleList extends StatelessWidget {
  final String raceId;

  RaceScheduleList({Key? key, required this.raceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This could be fetched from a database in a real app
    return Column(
      children: [
        RaceScheduleCard(day: '07 APR', session: 'Race', time: '08:00'),
        RaceScheduleCard(day: '06 APR', session: 'Qualifying', time: '09:00 - 10:00'),
        RaceScheduleCard(
          day: '06 APR',
          session: 'Practice 3',
          time: '05:30 - 06:30',
        ),
        RaceScheduleCard(
          day: '05 APR',
          session: 'Practice 2',
          time: '09:00 - 10:00',
        ),
        RaceScheduleCard(
          day: '05 APR',
          session: 'Practice 1',
          time: '05:30 - 06:30',
        ),
      ],
    );
  }
}






class Circuit extends StatelessWidget {
  final String raceId;

  Circuit({Key? key, required this.raceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch race details to get the track ID
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Calendar').doc(raceId).get(),
      builder: (context, raceSnapshot) {
        if (raceSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!raceSnapshot.hasData || raceSnapshot.hasError) {
          return Center(child: Text('Race details not found.'));
        }

        // Once you have the race data, extract the track ID to fetch track details
        final raceData = raceSnapshot.data!.data() as Map<String, dynamic>;
        final trackId = raceData['Track'];

        // Now fetch track details
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Tracks').doc(trackId).get(),
          builder: (context, trackSnapshot) {
            if (trackSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!trackSnapshot.hasData || trackSnapshot.hasError) {
              return Center(child: Text('Track details not found.'));
            }

            final trackData = trackSnapshot.data!.data() as Map<String, dynamic>;

            // Construct the UI with track data
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    color: Colors.grey[200], // Light grey background
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trackData["Name"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'First Grand Prix: ${trackData["FirstGP"]}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Circuit Length: ${trackData["CircuitLength"]} km',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Number of Laps: ${trackData["NumberOfLaps"]} ',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Race Distance: ${trackData["RaceDistance"]} km',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Lap Record: ${trackData["LapRecord"]}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  // Map of the circuit
                  Image.network(
                    trackData["CircuitMapImage"], // Replace with an actual map image of the circuit
                    fit: BoxFit.cover,
                  ),
                  // Additional content like onboard lap, race report, etc.
                  ListTile(
                    title: Text('Onboard Lap'),
                    leading: Icon(Icons.play_circle_fill),
                    onTap: () {
                      // TODO: Navigate to onboard lap video
                    },
                  ),
                  ListTile(
                    title: Text('2023 Race Report'),
                    leading: Icon(Icons.article),
                    onTap: () {
                      // TODO: Navigate to race report
                    },
                  ),
                  // Add more ListTile widgets for other sections
                ],
              ),
            );








          },
        );
      },
    );




  }
}






class RaceScheduleCard extends StatelessWidget {
  final String day;
  final String session;
  final String time;

  const RaceScheduleCard({
    Key? key,
    required this.day,
    required this.session,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

* */