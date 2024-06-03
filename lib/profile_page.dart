


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _imageurl;
      String _imageName="";

  final ImagePicker _picker=ImagePicker();
  @override
  void initState() {

    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async{
    var profileImageSnapShot= await FirebaseFirestore.instance.collection('profile').doc('user_id').get();
    if(profileImageSnapShot.exists){
      setState(() {
        _imageurl=profileImageSnapShot['imageUrl'];
        _imageName=profileImageSnapShot['imageName'];
      });
    }
}
  //image pick method
  Future<void>_pickAndUploadImage() async{
    final pickedFile=await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      File file= File(pickedFile.path);
      String filename='profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
      try{
        TaskSnapshot snapshot=await FirebaseStorage.instance.ref().child(filename).putFile(file);
        //Get image download url
        String downloadURL=await snapshot.ref.getDownloadURL();
        //save imageurl to firestore
        await FirebaseFirestore.instance.collection('profile').doc('user_id').set(
          {
            'imageUrl': downloadURL,
            'imageName': filename,
          }
        );
        setState(() {
          _imageurl=downloadURL;
        });
      }
      catch(e){
        print('heda============${e}');
      }

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageurl!=null ? NetworkImage(_imageurl!): null,
              child: _imageurl==null ? Icon(Icons.person,size: 50): null,

            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _pickAndUploadImage, child: Text('Change Profile Picture'))
          ],
        )
      ),
    );
  }
}
