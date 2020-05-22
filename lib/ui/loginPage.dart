import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:hello_obp_flutter/utils/auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

typedef LoginCallback = void Function(User user);

class LoginPage extends StatefulWidget {
  final VoidCallback loginFun;

  LoginPage(this.loginFun, {key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _userName;
  String _password;

  // manage state of modal progress HUD widget
  bool _isLoading = false;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        setState(() {
          this._isLoading = true;
        });
        User user = await auth.signInWithUserNameAndPassword(
            _userName, _password);
        if (user != null) {
          // dismiss keyboard during async call
          FocusScope.of(context).requestFocus(FocusNode());
          this.widget.loginFun();
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: ListTile(leading: Icon(
                Icons.warning,
                color: Colors.yellow,
              ),
                title: Text('Incorrect User name or password!'),
              )));
        }
      } catch (e) {
        print('Error: $e');
        Scaffold.of(context).showSnackBar(SnackBar(
            content: ListTile(leading: Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
              title: Text('Login fail, for server side error!'),
            )));
      } finally {
        setState(() {
          this._isLoading = false;
        });
      }
    }
  }

  void googleLogin(BuildContext context) async {
    try {
      setState(() {
        this._isLoading = true;
      });
      User user = await auth.sinInWithSocial();
      if (user != null) {
        this.widget.loginFun();
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: ListTile(leading: Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
             title: Text('Login fail, for server side error! Please retry.'),
            )
        ));
      }
    } finally {
      setState(() {
        this._isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _isLoading,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: Builder(
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
                      "Onboarding",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontSize: 24.0),
                    ),
                    SizedBox(
                      height: 24.0,
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
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 18),
                            ),
                            textColor: Colors.white,
                            color: Colors.green,
                            onPressed: () => this.validateAndSubmit(context),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Text(
                          '- Or -',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    GoogleSignInButton(
                      textStyle: TextStyle(fontSize: 15, color: Colors.white),
                      splashColor: Colors.green,
                      onPressed: () => this.googleLogin(context),
                      darkMode: true, // default: false
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
