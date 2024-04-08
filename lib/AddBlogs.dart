import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() {
  runApp(MaterialApp(
    title: 'Blog Post Creator',
    theme: ThemeData(
      backgroundColor: Colors.blue,
      //visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: BlogPostCreator(),
  ));
}

class BlogPostCreator extends StatefulWidget {
  @override
  _BlogPostCreatorState createState() => _BlogPostCreatorState();
}

class _BlogPostCreatorState extends State<BlogPostCreator> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final imageController = TextEditingController();
  final blogTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Post Creator'),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Blog Title',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the title of the blog',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the image URL',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: blogTextController,
                  decoration: InputDecoration(
                    labelText: 'Blog Text',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the text for your blog',
                  ),
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the text for the blog';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  child: Text('Create Blog Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Use the text in the controllers to add a blog post to Firestore
                      try {
                        await FirebaseFirestore.instance.collection('blogs').add({
                          'Title': titleController.text,
                          'ImageURL': imageController.text,
                          'BlogText': blogTextController.text,
                        });
                        print('Blog post added to Firestore');
                        // Clear the form fields after the blog post is added
                        titleController.clear();
                        imageController.clear();
                        blogTextController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Blog post created successfully!')),
                        );
                      } catch (e) {
                        print('Error adding blog post to Firestore: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create blog post. Please try again.')),
                        );
                      }
                    }
                  },
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
    titleController.dispose();
    imageController.dispose();
    blogTextController.dispose();
    super.dispose();
  }
}
