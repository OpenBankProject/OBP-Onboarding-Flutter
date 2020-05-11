import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'constant.dart';
import 'http_utils.dart';

abstract class BaseAuth {
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

  Future<void> signOut() async {
    user = null;
    authHeaders = {};
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

  Future<User> sinInWithSocial();
}

class GoogleAuth extends BaseAuth {
  GoogleAuth._privateConstructor();

  static final GoogleAuth instance = GoogleAuth._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid'
    ],
  );
  GoogleSignInAccount signInAccount;

  @override
  Future<User> sinInWithSocial() async {

    signInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await signInAccount.authentication;

//    final AuthCredential credential = GoogleAuthProvider.getCredential(
//      accessToken: googleSignInAuthentication.accessToken,
//      idToken: googleSignInAuthentication.idToken,
//    );
//
//    final AuthResult authResult =
//    await _auth.signInWithCredential(credential);
//    final FirebaseUser user = authResult.user;

    authHeaders = {
      'Authorization': 'Bearer ${googleSignInAuthentication.idToken}',
      'Content-Type': 'application/json'
    };
    ObpResponse response = await httpRequest.get(constants.currentUserUrl, headers: authHeaders);
    user = User.fromJson(response.data);
    user.photoUrl = signInAccount.photoUrl;
    return user;
  }

  Future<void> signOut() async {
    user = null;
    authHeaders = {};
    _googleSignIn.signOut();
  }

}

GoogleAuth googleAuth = GoogleAuth.instance;
