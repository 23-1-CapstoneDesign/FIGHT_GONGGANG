import 'package:fighting_gonggang/Maintab/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Layout/Dashboard.dart';

import 'Maintab/home.dart';
import 'Maintab/comunity.dart';
import 'Maintab/mypage.dart';
import 'Maintab/party.dart';
import 'Maintab/map.dart';
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
    TestPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: ()  async {
      if (_lastPressedTime == null ||
          DateTime.now().difference(_lastPressedTime!) > Duration(seconds: 2)) {
        // 첫 번째 뒤로가기 버튼 클릭 시
        _lastPressedTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('한 번 더 누르면 종료됩니다.')),
        );
        return false; // 뒤로가기 버튼 막음
      } else {
        // 두 번째 뒤로가기 버튼 클릭 시
        SystemNavigator.pop(); // 앱을 종료시킴
        return true;
      }
    },
      child:Scaffold(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'TEST',
          ),

        ],
      ),
          drawer: Drawer(
    child: dashboard()),
    ),
    );
  }

  void onTabTapped(int index) {
    if(index==2){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MapPage()));

    }
    else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
