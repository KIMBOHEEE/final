
import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';
import 'detail.dart';
import 'db.dart';
import 'edit.dart';
import 'add.dart';
import 'mypage.dart';

// TODO: Convert ShrineApp to stateful widget (104)
class ShrineApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      home: HomePage(),
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
      routes: <String, WidgetBuilder>{
        '/home' : (BuildContext context) => HomePage(),
        '/detail' : (BuildContext context) => DetailPage(),
        '/edit' : (BuildContext context) => EditPage(),
        '/add' : (BuildContext context) => AddPage(),
        '/mypage' : (BuildContext context) => MyPagePage(),
      },
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}

