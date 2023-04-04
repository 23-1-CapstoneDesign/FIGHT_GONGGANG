import 'package:flutter/material.dart';
import 'Layout/Dashboard.dart';

import 'Maintab/home.dart';
import 'Maintab/comunity.dart';
import 'Maintab/mypage.dart';
import 'Maintab/party.dart';
import 'login.dart';

class MaintabPage extends StatefulWidget {
  @override
  _MaintabPageState createState() => _MaintabPageState();
}

class _MaintabPageState extends State<MaintabPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    PartyPage(),
    PartyPage(),
    ComunityPage(),
    Mypage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label:'Main',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Party',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.location_on),
            label:"지도",

          )
          ,
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: 'Mypage',

          ),
        ],
      ),
          drawer: Drawer(
    child: dashboard()),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if(_currentIndex==2){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));

    }
  }
}
