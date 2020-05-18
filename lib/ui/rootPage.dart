import 'package:flutter/material.dart';
import 'package:hello_obp_flutter/ui/loginPage.dart';
import 'package:hello_obp_flutter/ui/mainPage.dart';
import 'package:hello_obp_flutter/utils/auth.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isLoggedIn = false;

  _login() async {
    setState(() {
      _isLoggedIn = true;
    });
  }

  _logout() async{
    await auth.signOut();
    setState(() {
      _isLoggedIn = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? MainPage(_logout) : LoginPage(_login);
  }
}
