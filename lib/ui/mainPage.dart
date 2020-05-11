import 'package:flutter/material.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:hello_obp_flutter/utils/auth.dart';
import 'package:hello_obp_flutter/utils/constant.dart';
import 'package:hello_obp_flutter/utils/http_utils.dart';

import 'authContextUpdatePage.dart';

class MainPage extends StatefulWidget {
  final User user;
  final VoidCallback logout;

  MainPage({this.user, this.logout, Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _pagelist = [
    Scaffold(body: BanksPage()),
    Scaffold(body: AuthContextUpdatePage()),
  ];
  List<Widget> _tabs = [
    Tab(
      text: 'Banks',
      icon: Icon(Icons.person),
    ),
    Tab(
      text: 'Auth Context Update',
      icon: Icon(Icons.domain),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Open Bank Project',
              style: TextStyle(fontSize: 14),
            ),
            centerTitle: true,
            // leading: Icon(Icons.menu),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20),
                child: Icon(Icons.monetization_on),
              )
            ],
          ),
          body: TabBarView(
            // 3. 使用 DefaultTabController 之后，这里不再需要 controller 属性
            // controller: _controller,
            children: _pagelist,
          ),
          drawer: Drawer(
            child: Container(
              decoration: BoxDecoration(color: Colors.black87),
              child: ListView(padding: EdgeInsets.zero, children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(this.widget.user.username),
                  accountEmail: Text(this.widget.user.email),
                  currentAccountPicture: this.userPhoto(),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image:
                              AssetImage('assets/img/about-background.jpg'))),
                ),
                ListTile(
                  title:
                      Text('Settings', style: TextStyle(color: Colors.white)),
                  trailing: Icon(Icons.settings, color: Colors.white),
                  onTap: () {
                    print("click Settings");
                  },
                ),
                ListTile(
                  title: Text('Logout', style: TextStyle(color: Colors.white)),
                  trailing: Icon(Icons.exit_to_app, color: Colors.white),
                  onTap: this.widget.logout,
                )
              ]),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: Colors.grey, width: 1))),
            height: 50,
            child: TabBar(
              // controller: _controller,
              tabs: _tabs,
              indicatorColor: Colors.red,
              labelStyle: TextStyle(height: 0, fontSize: 10),
            ),
          )),
    );
  }

  Widget userPhoto() {
    var photoUrl = this.widget.user?.photoUrl;
    if (photoUrl != null) {
      return Image.network(
        photoUrl,
        height: 50.0,
        width: 50.0,
      );
    } else {
      return Icon(
        Icons.person,
        size: 50,
        color: Colors.lightGreenAccent,
      );
    }
  }
}

class BanksPage extends StatefulWidget {
  @override
  _BanksPageState createState() => _BanksPageState();
}

class _BanksPageState extends State<BanksPage> {
  List<Bank> banks = List();
  List<Entitlement> entitlemments = List();

  @override
  void initState() {
    super.initState();
    if (banks.isEmpty) {
      httpRequest.get(constants.getBanksUrl).then((response) {
        if (response.isSuccess()) {
          var banksJson = response.data["banks"] as List<dynamic>;
          setState(() {
            banks = banksJson.map<Bank>((it) => Bank.fromJson(it)).toList();
          });
        }
      });
    }

    googleAuth.getEntitlements().then((roles) {
      setState(() {
        entitlemments = roles;
      });
    });
  }

  bool isRolesReady(String bankId) {
//    CanCreateCustomer bankid
//    CanCreateUserCustomerLink bankId
//    CanCreateUserAuthContextUpdate
//    CanGetUserAuthContext
    bool hasCanCreateCustomer = false;
    bool hasCanCreateUserCustomerLink = false;
    bool hasCanCreateUserAuthContextUpdate = false;
    bool hasCanGetUserAuthContext = false;
    entitlemments.forEach((Entitlement entitlement) {
      if (entitlement.role_name == 'CanCreateCustomer' &&
          entitlement.bank_id == bankId) {
        hasCanCreateCustomer = true;
      } else if (entitlement.role_name == 'CanCreateUserCustomerLink' &&
          entitlement.bank_id == bankId) {
        hasCanCreateUserCustomerLink = true;
      } else if (entitlement.role_name == 'CanCreateUserAuthContextUpdate') {
        hasCanCreateUserAuthContextUpdate = true;
      } else if (entitlement.role_name == 'CanGetUserAuthContext') {
        hasCanGetUserAuthContext = true;
      }
    });
    return hasCanCreateCustomer &&
        hasCanCreateUserCustomerLink &&
        hasCanCreateUserAuthContextUpdate &&
        hasCanGetUserAuthContext;
  }

  void requestRoles(String bankId) {
    String userId = googleAuth.user.user_id;
    List<String> requestRoles = <String>[
      '{"bank_id":"$bankId",  "role_name":"CanCreateCustomer"}',
      '{"bank_id":"$bankId",  "role_name":"CanCreateUserCustomerLink"}',
      '{"bank_id":"", "role_name":"CanCreateUserAuthContextUpdate"}',
      '{"bank_id":"", "role_name":"CanGetUserAuthContext"}',
    ];
    requestRoles.forEach((role) {
      httpRequest.post(constants.requestRoleUrl,
          headers: googleAuth.authHeaders, data: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => ListView(
          children: List.generate(banks.length, (int index) {
            var name = banks[index].full_name;
            var id = banks[index].id;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.account_balance,
                      color: Colors.deepPurpleAccent,
                    ),
                    Text(
                      '  Bank Name: $name',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '       Bank id: $id',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    isRolesReady(id)
                        ? Text(
                            'roles are ready',
                            style: TextStyle(
                                color: Colors.lightGreen, fontSize: 20),
                          )
                        : RaisedButton(
                            child: Text('request Auth Context roles'),
                            color: Colors.green,
                            onPressed: () {
                              requestRoles(id);
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text('Requesting Roles...')));
                            },
                            textColor: Colors.white)
                  ],
                ),
                Divider(
                  thickness: 1,
                  indent: 16.0,
                  endIndent: 16.0,
                  height: 1,
                  color: Colors.grey,
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
