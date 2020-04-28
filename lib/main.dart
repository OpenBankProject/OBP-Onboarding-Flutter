import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

Future<String> getUser() async {
  // produces a request object

  print("entering getUser");
  String url = 'https://apisandbox.openbankproject.com/obp/v3.0.0/users/current';
  print(GlobalConfiguration().getString("direct_login_token"));
  var  response = await http.get(url, headers: {HttpHeaders.authorizationHeader: 'DirectLogin token=' + GlobalConfiguration().getString("direct_login_token")},);
  // sends the request
  return response.body.toString();
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(MyApp(user: getUser()));
}

class MyApp extends StatelessWidget {

  final Future<String> user;
  MyApp({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Display User',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Display User'),
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: user,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
// By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
