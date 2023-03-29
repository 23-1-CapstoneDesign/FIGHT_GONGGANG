import 'package:flutter/material.dart';
import 'Login.dart';
import 'Maintab.dart';
import 'dbconfig/dbconnect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future main() async{

  await dotenv.load(fileName: ".env");

  var test = config();
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

      initialRoute: '/',
      routes: {//routes: key=라우트명 ex:localhost:8080/라우트명
        '/': (context) => LoginPage(),
        '/home': (context) => MaintabPage(),
        // '/profile': (context) => ProfileScreen(),
        // '/settings': (context) => SettingsScreen(),

      },
    );
  }
}

