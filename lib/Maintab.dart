import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Layout/Dashboard.dart';

import 'Maintab/comunity/community_main.dart';
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
    CommunityPage(),
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
              icon: Icon(Icons.account_balance), label: 'TEST2')
        ],
      ),
      drawer: Drawer(child: dashboard()),
    );
  }

  void onTabTapped(int index) {
    if (index == 2) {
      Permission.location.request();
      Permission.location.status.then((val) {
        if (val.isDenied) {
          Permission.location.request().then((val) {
            if (val.isDenied) {
              Fluttertoast.showToast(
                msg: "위치 권한이 거부되어 사용할 수 없습니다.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MapPage()));
            }
          });
        }
        else{
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MapPage()));
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
