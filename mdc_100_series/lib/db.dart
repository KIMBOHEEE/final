import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

String userID;

class Record {
  final String name;
  final int prices;
  final String image;
  final DocumentReference reference;
  final String uid;
  final String info;
  final String category;
  final String createTime;
  final String modifiedTime;
  final int like;
  String documentID;
  List<dynamic> likeUser;

  Record.fromMap(Map<String, dynamic> map, String docID, {this.reference})
      : assert(map['name'] != null),
        assert(map['price'] != null),
        name = map['name'],
        image = map['image'],
        prices = map['price'],
        uid = map['uid'],
        info = map['info'],
        category = map['category'],
        like = map['like'],
        documentID = docID,
        likeUser=map['likeUser'],
        modifiedTime = map['modifiedTime'],
        createTime = map['createTime'];


  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.documentID, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$prices:$image:$prices:$uid:$info:$category:$createTime:$like:$modifiedTime>";
}
