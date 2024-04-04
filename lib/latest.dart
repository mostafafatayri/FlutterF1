import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: LatestNewsPage(),
  ));
}

class LatestNewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest F1 News'),
        backgroundColor: Color(0xFFD50000),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 2,
        ),
        itemCount: 20, // Number of items in the grid
        itemBuilder: (context, index) {
          // Assuming you have a list of news items, replace with actual data
          return NewsCard(
            title: 'News Item #$index',
            imageUrl: 'image2.png', // Replace with actual image path
            category: 'Category $index',
          );
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String category;

  const NewsCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
