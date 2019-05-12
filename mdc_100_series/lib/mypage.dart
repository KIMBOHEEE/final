import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

FirebaseUser mCurrentUser;
String email;
String imageurl;

class MyPagePage extends StatefulWidget {
  @override
  _MyPagePageState createState() {
    return _MyPagePageState();
  }
}

class _MyPagePageState extends State<MyPagePage> {
  _getCurrentUser () async {
    mCurrentUser = await FirebaseAuth.instance.currentUser();
    if(mCurrentUser.isAnonymous) {
      email = 'anonymous';
      imageurl = 'https://screenshotlayer.com/images/assets/placeholder.png';
    }
    else{
      email = mCurrentUser.email;
      imageurl = mCurrentUser.photoUrl;
    }

  }


  @override
  Widget build(BuildContext context) {
    _getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        title: Text('My Page'),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/home');
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/login');
              }
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 80.0),
          Container(
            child:
            Image.network(imageurl, width: 180, height: 150),
          ),
          SizedBox(height: 20.0),
          Text(mCurrentUser.uid,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center
          ),
          SizedBox(height: 12.0),
          Divider(height: 16.0),
          Text(email,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center
          ),
        ],
      ));
  }
}
