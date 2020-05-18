import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_obp_flutter/utils/auth.dart';

import 'authContextUpdatePage.dart';
import 'customersPage.dart';

class MainPage extends StatefulWidget {
  final VoidCallback logout;

  MainPage(this.logout, {Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _pagelist = [
    Scaffold(body: AuthContextUpdatePage()),
    Scaffold(body: CustomersPage()),
  ];
  List<Widget> _tabs = [
    Tab(
      text: 'Request Access',
      icon: Icon(CommunityMaterialIcons.comment_question),
    ),
    Tab(
      text: 'Customers',
      icon: Icon(Icons.person),
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
                  accountName: Text(''), // temp set account name blank
                  accountEmail: Text(auth.user.email),
                  currentAccountPicture: this._userPhoto(),
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

  Widget _userPhoto() {
    var photoUrl = auth.user?.photoUrl;
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

