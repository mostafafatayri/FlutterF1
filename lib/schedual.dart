import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'fullRaceDetails.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Schedule 2024',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: F1SchedulePage(),
    );
  }
}

class F1SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 Schedule 2024'),
        backgroundColor: Color(0xFFD50000),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Calendar').orderBy('StartDate').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No races found'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: MediaQuery.of(context).size.width > 1200 ? 1 / 0.8 : 1,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var race = snapshot.data!.docs[index];
              var raceData = race.data() as Map<String, dynamic>;
              String startDate = raceData['StartDate'];
              String endDate = raceData['EndDate'];
              String month = DateFormat('MMM').format(DateTime.parse(startDate));
              String dateRange = DateFormat('d').format(DateTime.parse(startDate)) +
                  '-' +
                  DateFormat('d').format(DateTime.parse(endDate));

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Tracks').doc(raceData['Track']).get(),
                builder: (context, trackSnapshot) {
                  if (!trackSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (trackSnapshot.hasError) {
                    return Center(child: Text('Error fetching track image'));
                  }
                  var trackData = trackSnapshot.data!.data() as Map<String, dynamic>;
                  print("the race id is ${race.id}");
                  return RaceCard(
                    roundNumber: index + 1,
                    country: trackData['Country'] ?? 'Unknown',
                    grandPrixName: raceData['Title'],
                    month: month,
                    dateRange: dateRange,
                    trackImage: trackData['CircuitImage'],
                    raceId: race.id, // This should be the unique identifier for the race
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class RaceCard extends StatelessWidget {
  final int roundNumber;
  final String country;
  final String grandPrixName;
  final String dateRange;
  final String trackImage;
  final String month;
  final String raceId; // This should be passed from F1SchedulePage

  const RaceCard({
    Key? key,
    required this.roundNumber,
    required this.country,
    required this.grandPrixName,
    required this.dateRange,
    required this.trackImage,
    required this.month,
    required this.raceId, // Ensure this parameter is required and passed in
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Use raceId which is passed into this widget
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  RaceWeekendPage(raceId: raceId),//RaceDetailsPage(raceId: raceId),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                trackImage,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ROUND $roundNumber', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(month + ' ' + dateRange),
                  Text(country, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(grandPrixName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
