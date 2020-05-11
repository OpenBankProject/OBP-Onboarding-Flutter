import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:hello_obp_flutter/utils/auth.dart';

typedef LoginCallback = void Function(User user);

class LoginPage extends StatefulWidget {
  final LoginCallback loginFun;

  LoginPage(this.loginFun, {key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _userName;
  String _password;
  String _wrongUserNameOrPassword = '';

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        User user = await googleAuth.signInWithUserNameAndPassword(
            _userName, _password);
        if (user != null) {
          this.widget.loginFun(user);
        } else {
          setState(() {
            _wrongUserNameOrPassword = 'Wrong user name or password.';
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _wrongUserNameOrPassword = 'Error: $e';
        });
      }
    }
  }
  void googleLogin() async {
    User user = await googleAuth.sinInWithSocial();
    if(user != null) {
      this.widget.loginFun(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context) => SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 120.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                          child: Image.asset('assets/img/logo.png',
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      "Open Bank",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontSize: 24.0),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      this._wrongUserNameOrPassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 15.0),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 26.0, left: 42.0, right: 42.0),
                      child: Container(
                        width: double.infinity,
                        height: 140.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                          border:
                              Border.all(color: Color(0xFFF1F1F1), width: 1),
                        ),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 18.0, bottom: 6.0),
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'User Name',
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) => value.isEmpty
                                        ? 'UserName can\'t be empty'
                                        : null,
                                    onSaved: (value) => _userName = value,
                                    initialValue: 'susan.xuk.x@example.com',
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              indent: 16.0,
                              endIndent: 16.0,
                              height: 1,
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 18.0, bottom: 6.0),
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: InputBorder.none,
                                    ),
                                    obscureText: true,
                                    validator: (value) => value.isEmpty
                                        ? 'Password can\'t be empty'
                                        : null,
                                    onSaved: (value) => _password = value,
                                    initialValue: '43ca4d',
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 42.0,
                        right: 42.0,
                        top: 32.0,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: RaisedButton(
                                child: Text("Login"),
                                textColor: Colors.white,
                                color: Colors.green,
                                onPressed: () {
                                  Scaffold.of(context).showSnackBar(
                                      SnackBar(content: Text('Logining...')));
                                  this.validateAndSubmit();
                                },
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: GoogleSignInButton(
                          onPressed: () {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Logining...')));
                           this.googleLogin();
                          },
                          darkMode: true, // default: false
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 36.0,
                      ),
                      child: Container(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                              children: [
                                TextSpan(
                                  text: "Forgot your password?",
                                  style: TextStyle(
                                    color: Color(0xff9B9B9B),
                                  ),
                                ),
                                TextSpan(
                                  text: "\nTo ",
                                  style: TextStyle(
                                    color: Color(0xff9B9B9B),
                                  ),
                                  children: [
                                    TextSpan(
                                        text: "Recover password",
                                        style: TextStyle(
                                          color: Color(0xFF5D86C1),
                                        ))
                                  ],
                                ),
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
