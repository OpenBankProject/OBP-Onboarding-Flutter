import 'package:flutter/material.dart';
import 'model/model.dart';
import 'ui/login.dart';
import 'ui/mainPage.dart';
import 'utils/auth.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  User _user;

  _login(User user) async {
    //Scaffold.of(context).showSnackBar(SnackBar(content:Text('Logining...')));

    try {
      setState(() {
        _isLoggedIn = true;
        _user = user;
      });
    } on Exception catch (err) {
      print(err);
    }
  }

  _logout() async {
    await googleAuth.signOut();
    setState(() {
      _isLoggedIn = false;
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Open Bank",
      home: _isLoggedIn ? MainPage(user:_user, logout: _logout) : LoginPage(_login),
    );
  }
}


