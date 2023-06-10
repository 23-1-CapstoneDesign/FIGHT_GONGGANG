import 'package:fighting_gonggang/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



/*
≡ <- 이런 모양의 버튼을 클릭했을 때 나타나는 대쉬보드
 */
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});




    @override
    Widget build(BuildContext context) {
  return ListView(
    padding: EdgeInsets.zero,
    children: <Widget>[
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.green,
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
        leading: const Icon(Icons.logout),
        title: const Text('로그아웃'),
        onTap: () async {
// 로그아웃 처리 로직
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('username');
          await prefs.remove('password');
          await prefs.remove('isLogin');

          await FirebaseAuth.instance.signOut();
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
