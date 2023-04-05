import 'package:flutter/material.dart';
import 'Login.dart';
import 'Maintab.dart';
import 'dbconfig/dbconnect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
/*
* main 함수가 존재하는 구역
* 전역적으로 데이터를 로드할 일이 있다면 이곳에 넣으면 될듯... 이 이상은 저도 잘 몰라용
*
* 라우팅(주소창에 입력될 주소명)명을 지정하려면 아래에서 작성하면 됩니당.
*
 */

Future main() async{

  await dotenv.load(fileName: ".env");
  var db= Database.instance;

  var a= await getCurrentLocation();
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

      initialRoute: '/',// 앱에서 기본으로 실행될 페이지( 여기선 로그인)
      routes: {//routes: key=라우트명 ex:localhost:8080/라우트명
        '/': (context) => LoginPage(),
        '/home': (context) => MaintabPage(),


      },
    );
  }
}

