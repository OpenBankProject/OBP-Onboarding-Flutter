import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'constant.dart';
import 'http_utils.dart';

class AuthUtil {
  AuthUtil._privateConstructor();

  static final AuthUtil instance = AuthUtil._privateConstructor();

  User user;

  Map<String, String> authHeaders = {};

  Future<User> signInWithUserNameAndPassword(String userName, String password) async {
    Map<String, String> headers = {
      'Authorization': 'DirectLogin username="$userName",password="$password",consumer_key="${constants.consumerKey}"',
      'Content-Type': 'application/json'
    };
    ObpResponse response;
    try{
      response = await httpRequest.post(constants.directLoginUrl, headers: headers);
    } on Exception catch (e) {
      print(e);
    }
    if(response.isSuccess()) {
      var json = response.data;
      if(json["token"] != null) {
        String token = json["token"] as String;
        authHeaders = {
          'Authorization': 'DirectLogin token="$token"',
          'Content-Type': 'application/json'
        };

        await getEntitlements();
        return user;
      } else {
        user = null;
        authHeaders = null;
        return null;
      }
    } else {
      return null;
    }

  }

  Future<List<Entitlement>> getEntitlements() async {
    ObpResponse response  = await httpRequest.get(constants.currentUserUrl, headers: authHeaders);

    if(response.isSuccess()) {
      var json = response.data;
      user = User.fromJson(json);
      return user != null ? user.entitlements : List<Entitlement>();
    } else {
      return List<Entitlement>();
    }
  }

  // google login related

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid'
    ],
  );
  GoogleSignInAccount signInAccount;


  resetHeader(GoogleSignInAccount account) async{
    final GoogleSignInAuthentication googleSignInAuthentication =
    await account.authentication;

    authHeaders = {
      'Authorization': 'Bearer ${googleSignInAuthentication.idToken}',
      'Content-Type': 'application/json'
    };
  }

  @override
  Future<User> sinInWithSocial() async {

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      resetHeader(account);
    });
//    _googleSignIn.signInSilently();

    try {
      signInAccount = await _googleSignIn.signIn();

      resetHeader(signInAccount);

      ObpResponse response = await httpRequest.get(constants.currentUserUrl, headers: authHeaders);
      if(response.isSuccess()) {
        user = User.fromJson(response.data);
        user.photoUrl = signInAccount.photoUrl;
      } else {
        user = null;
        print(response.message);
      }
    } on Exception catch (e) {
      print(e);
    }

    return user;
  }

  Future<void> signOut() async {
    user = null;
    authHeaders = {};
    try {
      _googleSignIn.signOut();
    } on Exception catch (e) {
      print(e);
    }
  }

}

AuthUtil auth = AuthUtil.instance;
