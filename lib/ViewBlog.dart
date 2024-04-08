import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() {
  runApp(MaterialApp(
    title: 'Formula 1 Mini Site',
    theme: ThemeData(
      primarySwatch: Colors.red,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: ViewBlogPage(blogId: 'id'),
  ));
}

class ViewBlogPage extends StatelessWidget {
  final String blogId;

  ViewBlogPage({required this.blogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Details'),
        backgroundColor: Colors.red[900],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('blogs').doc(blogId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Document does not exist"));
          }
          if (snapshot.data!.exists) {
            Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Text(data['Title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Image.network(data['ImageURL']),
                SizedBox(height: 10),
                Text(data['BlogText']),
              ],
            );
          } else {
            return Center(child: Text("Document does not exist"));
          }
        },
      ),
    );
  }
}
