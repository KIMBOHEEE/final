import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'db.dart' as db;

class EditPage extends StatefulWidget {
  db.Record record;
  EditPage({Key key, this.record}) : super(key: key);
  @override
  _EditPageState createState() => new _EditPageState(record: record);
}

String accountStatus = '******';
FirebaseUser mCurrentUser;
FirebaseAuth _auth;
List like = [];
String imageUrl;

var _nameController = TextEditingController();
var _priceController = TextEditingController();
var _infoController = TextEditingController();
var _categoryController = TextEditingController();

class _EditPageState extends State<EditPage> {
  db.Record record;
  _EditPageState({this.record});
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _getCurrentUser() async {
    mCurrentUser = await FirebaseAuth.instance.currentUser();
    print(mCurrentUser.uid.toString());
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: record.name);
    _priceController = TextEditingController(text: record.prices.toString());
    _infoController = TextEditingController(text: record.info);
    _categoryController = TextEditingController(text: record.category);
    imageUrl = record.image;
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        title: Text('Edit'),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () {
              DateTime now = DateTime.now();
              String formattedDate =
              DateFormat('yyyy-MM-dd – kk:mm').format(now);
              record.reference.updateData({
                'image': imageUrl,
                'name': _nameController.text,
                'price': int.parse(_priceController.text),
                'info': _infoController.text,
                'category': _categoryController.text,
                'modifiedTime': formattedDate
              });
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/home');
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('product')
          .document(record.documentID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildDetail(context, snapshot.data);
      },
    );
  }

  Widget _buildDetail(BuildContext context, DocumentSnapshot data) {
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
      final StorageUploadTask task = firebaseStorageRef.putFile(_image);

      await (await task.onComplete).ref.getDownloadURL().then((dynamic url) {
        setState(() {
          imageUrl = url;
          _image = null;
        });
      });
    }

    final record = db.Record.fromSnapshot(data);

    return ListView(
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
        TextField(
          controller: _priceController,
          decoration: InputDecoration(
            filled: true,
            labelText: 'Price',
          ),
        ),
        // spacer
        SizedBox(height: 12.0),
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
    );
  }
}