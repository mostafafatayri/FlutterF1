import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Formula 1 Mini Site',
    theme: ThemeData(
      primarySwatch: Colors.red,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: ArticlePage(),
  ));
}

class ArticlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formula 1 Mini Site'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'FP1: Verstappen fastest during first practice at Suzuka as Sargeant crashes out heavily',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              SizedBox(height: 20),
              Image.network(
                'https://media.formula1.com/image/upload/f_auto,c_limit,w_1440,q_auto/f_auto/q_auto/fom-website/2024/Japan/verstappen-suzuka-practice-2024-1', // Replace with your image URL
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: 20),
              Text(
                'Blog:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              Text(
                // Blog text
                'Red Bull’s Max Verstappen posted the quickest time during Friday’s first practice session for the Japanese Grand Prix, leading the way from team mate Sergio Perez, while Logan Sargeant brought out the red flags with another sizeable FP1 accident for Williams. A largely dry but cool opening hour of practice initially saw drivers head out for laps on the medium and hard compound tyres, with reigning world champion Verstappen setting the pace on C1s from McLaren’s Lando Norris and Aston Martin’s Fernando Alonso on the C2s. PADDOCK INSIDER: Verstappen’s point to prove in Suzuka, the battle for a Red Bull seat and Tsunoda’s charge. Just as Mercedes’ Lewis Hamilton had made the switch to soft tyres, with more drivers expected to follow, Sargeant dipped a wheel on the grass as he rounded Dunlop Curve, lost control of his Williams and slammed into the barriers at the outside of the track. With significant contact at the front and rear, Williams now face another nervy break between FP1 and FP2 as they assess the damage and – given that they are still without a spare chassis – look to avoid the same situation that troubled them in Australia last time out.',
                style: TextStyle(fontSize: 16.0),
              ),
              // You can add more content here
            ],
          ),
        ),
      ),
    );
  }
}
