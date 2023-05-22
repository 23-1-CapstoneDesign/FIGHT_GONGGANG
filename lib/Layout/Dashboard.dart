import 'package:fighting_gonggang/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



/*
≡ <- 이런 모양의 버튼을 클릭했을 때 나타나는 대쉬보드


 */
class dashboard extends StatelessWidget {



    @override
    Widget build(BuildContext context) {
  return ListView(
    padding: EdgeInsets.zero,
    children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          '메뉴',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('내 정보'),
        onTap: () {
// Navigator.pushNamed(context, '/profile');
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('설정'),
        onTap: () {
// Navigator.pushNamed(context, '/settings');
        },
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('로그아웃'),
        onTap: () async {
// 로그아웃 처리 로직
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('autoLogin');
          await prefs.remove('username');
          await prefs.remove('password');
          await prefs.remove('isLogin');
          Navigator.pushAndRemoveUntil (
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,);


        },
      ),
    ],
  );
    }
  }
