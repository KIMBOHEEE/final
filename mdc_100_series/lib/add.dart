import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'db.dart' as db;
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';


class AddPage extends StatefulWidget {
  db.Record record;
  AddPage({Key key, this.record}) : super(key : key);

  @override
  _AddPageState createState() {
    return _AddPageState(record: record);
  }
}

String accountStatus = '******';
FirebaseUser mCurrentUser;
FirebaseAuth _auth;

final _nameController = TextEditingController();
final _priceController = TextEditingController();
final _infoController = TextEditingController();
final _categoryController = TextEditingController();

String imageUrl = 'https://screenshotlayer.com/images/assets/placeholder.png';

class _AddPageState extends State<AddPage> {
  db.Record record;
  _AddPageState({this.record});
  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
    print(_image);
    final String rand =
        "${new Random().nextInt(10000)}${DateTime.now().millisecond}";

    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('product').child('myimage.jpg');
    final StorageUploadTask task =
    firebaseStorageRef.putFile(_image);

    await (await task.onComplete)
        .ref
        .getDownloadURL()
        .then((dynamic url) {
      setState(() {
        imageUrl= url;
        _image = null;
      });}
    );
  }

  _getCurrentUser () async {
    mCurrentUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      mCurrentUser != null ? accountStatus = 'Signed In' : 'Not Signed In';
    });
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        leading: FlatButton(
          child: Text('Cancle'),
          onPressed: (){
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/home');
          },
        ),
        title: Text('Add'),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: (){
              DateTime now = DateTime.now();
              String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
              Firestore.instance.collection('product').document(_nameController.text).setData({
                'name':_nameController.text,
                'category':_categoryController.text,
                'price':int.parse(_priceController.text),
                'info':_infoController.text,
                'image': imageUrl,
                'uid' : mCurrentUser.uid,
                'createTime' : formattedDate,
                'modifiedTime' : '',
                'like' : 0,
                'likeUser' : [],
              });
              _nameController.clear();
              _priceController.clear();
              _infoController.clear();
              _categoryController.clear();

              Navigator.pop(context);
              Navigator.of(context).pushNamed('/home');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 10.0),
            Column(
              children: <Widget>[
                Image.network(imageUrl, fit: BoxFit.fill),
                SizedBox(height: 16.0),
              ],
            ),
            FlatButton(
              onPressed: getImage,
              child: Icon(Icons.add_a_photo),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Product Name',
              ),
            ),
            // spacer
            SizedBox(height: 12.0),
            // [Password]
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Price',
              ),
            ),
            // spacer
            SizedBox(height: 12.0),
            // [Password]
            TextField(
              controller: _infoController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Descripton',
              ),
            ),
            // spacer
            SizedBox(height: 12.0),
            // [Password]
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Category',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
