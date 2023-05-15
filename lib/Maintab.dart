import 'package:fighting_gonggang/Maintab/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Layout/Dashboard.dart';

import 'Maintab/home/home.dart';
import 'Maintab/comunity/comunity.dart';
import 'Maintab/mypage.dart';
import 'Maintab/party/party.dart';
import 'Maintab/map.dart';
import 'Maintab/timetable/Timetable.dart';
import 'Maintab/timetable/AddClass.dart';

import 'login.dart';

class MaintabPage extends StatefulWidget {
  @override
  _MaintabPageState createState() => _MaintabPageState();
}

class _MaintabPageState extends State<MaintabPage> {
  DateTime? _lastPressedTime;
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    PartyPage(),
    MapPage(),
    ComunityPage(),
    Mypage(),
    TimeTable(),
    AddClass(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Party',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "지도",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: 'Mypage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'TEST',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              label: 'TEST2'
          )
        ],
      ),
      drawer: Drawer(child: dashboard()),
    );
  }

  void onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapPage()));
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
