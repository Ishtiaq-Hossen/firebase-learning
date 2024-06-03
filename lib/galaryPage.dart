import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    var snapshot = await FirebaseFirestore.instance.collection('profile').get();
    setState(() {
      _imageUrls = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    });
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String filename = 'profileImage/profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
      try {
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child(filename).putFile(file);
        String downloadURL = await snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('profile').add({
          'imageUrl': downloadURL,
          'imageName': filename,
        });
        setState(() {
          _imageUrls.add(downloadURL);
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery Page"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickAndUploadImage,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8), // Space between icon and text
                Text('Add Photo'),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    _imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
