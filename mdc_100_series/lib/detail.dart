import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'db.dart' as db;
import 'edit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailPage extends StatefulWidget {
  db.Record record;
  DetailPage({Key key, this.record}) : super(key: key);
  @override
  _DetailPageState createState() => new _DetailPageState(record: record);
}

String accountStatus = '******';
FirebaseUser mCurrentUser;
FirebaseAuth _auth;
bool liked = false;

class _DetailPageState extends State<DetailPage> {
  db.Record record;
  _DetailPageState({this.record});
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _getCurrentUser () async {
    mCurrentUser = await FirebaseAuth.instance.currentUser();
    print(mCurrentUser.uid.toString());
  }

  bool isOwner() {
    _getCurrentUser();
    if (mCurrentUser.uid == record.uid) {
      return true;
    }
    else
      return false;
  }

  void showSnackBar(List like){
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:Text("I LIKE IT!"),
        duration: Duration(seconds: 3),
        action: SnackBarAction(label: 'Undo',
        onPressed: () {
          like.remove(mCurrentUser.uid.toString());
          record.reference.updateData({'likeUser': like });
          record.reference.updateData({'like': like.length});
        })
    )
    );
  }


  void showNoBar(List like){
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:Text("You can only do it oncce!"),
        duration: Duration(seconds: 2),
        action: SnackBarAction(label: 'Undo',
            onPressed: () {
              like.remove(mCurrentUser.uid.toString());
              record.reference.updateData({'likeUser': like });
              record.reference.updateData({'like': record.likeUser.length});
            })
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        title: Text('Detail'),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.create, color: Colors.white),
              onPressed: () {
                isOwner() ?
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => EditPage(record: record))):
                print("you are not owner");
              }
          ),
          IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                isOwner() ? record.reference.delete() : print("you are not owner");
              }
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('product').document(record.documentID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildDetail(context, snapshot.data);
      },
    );
  }


  Widget _buildDetail(BuildContext context, DocumentSnapshot data) {
    final record = db.Record.fromSnapshot(data);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return Column(
      children: <Widget>[
        Expanded(
          child:
          Image.network(record.image, fit: BoxFit.fill),
        ),
        SizedBox(height: 12.0),
        Text(record.category,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.left
        ),
        SizedBox(height: 12.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(record.name,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            IconButton(
                icon : Icon(Icons.thumb_up,  color: Colors.red),
                onPressed: (){
                  List like =[];

                  if(record.likeUser.length != 0 && record.likeUser.contains(mCurrentUser.uid.toString())){
                    showNoBar(like);
                  }else{
                    for(int i = 0; i < record.likeUser.length; i++){
                      like.add(record.likeUser[i]);
                    }
                    like.add(mCurrentUser.uid.toString());
                    for(int i=0; i<like.length; i++){
                      print(like[i]+'\n');
                    }
                    record.reference.updateData({'likeUser': like });
                    record.reference.updateData({'like': record.like + 1});
                    showSnackBar(like);
                  }
                }
            ),
            Text(record.like.toString()),
          ],
        ),
        SizedBox(height: 12.0),
        Text('\$'+record.prices.toString(),
          style: TextStyle(
              fontSize: 18,
              color: Colors.blueAccent),
          textAlign: TextAlign.left,
          maxLines: 1,
        ),
        SizedBox(height: 12.0),
        Divider(height: 16),
        SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(record.info,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueAccent),
              textAlign: TextAlign.left
          ),
        ),
        SizedBox(height: 60.0),
        Text('creator: ' + record.uid,
            style: TextStyle(
                fontSize: 10),
            textAlign: TextAlign.left
        ),
        Text('create time: ' + record.createTime,
            style: TextStyle(
                fontSize: 10),
            textAlign: TextAlign.left
        ),
        Text('modified time: ' + record.modifiedTime,
            style: TextStyle(
                fontSize: 10),
            textAlign: TextAlign.left
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}