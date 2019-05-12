import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail.dart';
import 'db.dart';
import 'mypage.dart';
import 'add.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        leading: new IconButton(
            icon: new Icon(
              Icons.account_circle,
              semanticLabel: 'profile',
            ),
           onPressed: (){
              print("my profile!!!!!!!");
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/mypage');
            }
        ),
        centerTitle: true,
        title: Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/add');
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('product').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return OrientationBuilder(
      builder:(context,orientation){
        return GridView.count(
          padding: const EdgeInsets.all(8.0),
          crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
          childAspectRatio: 8.0/9.0,
          children:
          snapshot.map((data) => _buildListItem(context, data)).toList(),
        );
     }
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 150.0,
                      height: 110.0,
                      child: Image.network(record.image, fit: BoxFit.contain,)
                    ),
                    Text(record.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,),
                    Text("\$" + record.prices.toString()),
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => DetailPage(record: record)));
                            },
                            child: Container(
                                child: Text('more', style: TextStyle(color: Colors.blue))
                            )
                        )
                    )
                  ],
                )),
    );
  }
}
