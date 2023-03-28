import 'package:flutter/material.dart';
import 'Login.dart';
import 'Maintab.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),//시작 페이지: 로그인
      routes: {//routes: key=라우트명 ex:localhost:8080/라우트명
        '/login': (context) => LoginPage(),
        '/home': (context) => MaintabPage(),
        // '/profile': (context) => ProfileScreen(),
        // '/settings': (context) => SettingsScreen(),

      },
    );
  }
}

