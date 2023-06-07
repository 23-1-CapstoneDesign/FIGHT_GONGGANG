import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fighting_gonggang/Maintab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SignUp.dart';
import 'package:fighting_gonggang/Layout/items.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'dbconfig/UserProvider.dart';

/*
로그인 페이지

함수 리스트
_checkAutoLogin(): 로그인 시 자동 로그인을 체크 했는 지 확인하는 함수, 체크 했을 시 이 페이지를 바로 건너 뜀.
_clickLogin(): 로그인 버튼을 눌렀을 때 호출 되는 함수. 호출시 자동로그인 체크 확인과 입력된 값을 바탕으로 login()에 떠넘기는 역할을 함.
_login(String id,String password): 입력창에 입력된 입력값을 바탕으로 로그인을 하게 되는 함수.

todo 로그인 검증 기능 구현 id와 비밀번호(sha-256)을 이용해 검증, 로그인시 로그인 세션(id정보)를 shared_preferences에 저장 로그아웃시 삭제

 */

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final dburl = dotenv.env["MONGO_URL"].toString();
  bool _loginfn = true;
  double height = 0;



  @override
  void initState() {
    super.initState();
    checkPermissions();
    checkLogin();
  }

  Future<void> checkLogin() async {
    User? user = await FirebaseAuth.instance.authStateChanges().first;

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MaintabPage()),
      );
    }
  }

  Future<void> checkPermissions() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied) {
      requestPermissions();
    } else {}
  }

  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.camera.request();
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // 비밀번호를 바이트로 변환
    var sha256Hash = sha256.convert(bytes); // SHA-256 해시 알고리즘 적용
    var hashedPassword = sha256Hash.toString(); // 해시값 반환
    return hashedPassword;
  }

  void clickLogin() async {
    if (mounted) {
      setState(() {
        _loginfn = false;
      });
    }
    var email = _emailController.text;
    var password = _passwordController.text;

    //todo 디버그모드에서만 사용
    assert(() {
      // email = "admin";
      // password = "admin1";

      email = "test1";
      password = "test12";
      return true;
    }());

    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool login = await _login(email, password);
    if (login) {
      prefs.setString('email', email);
      prefs.setString('password', password);
      prefs.setBool('isLogin', true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MaintabPage()),
      );
    } else {
      if (mounted) {
        setState(() {
          _loginfn = true;
        });
      }
      Fluttertoast.showToast(
        msg: "로그인에 실패하였습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // 파이어베이스 로그인
  Future<UserCredential?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '$email@sunmoon.ac.kr',
        password: password,
      );
      return userCredential;
    } catch (e) {
      // 로그인 실패 처리
      print('로그인 실패: $e');
      return null;
    }
  }

  // 로그인 처리
  Future<bool> _login(String email, String password) async {
    // 로그인 처리 이 들어가야할 구간
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');

    var find = await collection
        .findOne({'email': email, 'password': hashPassword(password)});

    bool login;

      UserCredential? userCredential = await signInUser(email, password);
    conn.close();
      if (find != null && userCredential != null) {
      prefs.setString('username', find['username']);

        return true;
      } else {
        return false;
      }

  }

  void showLoginErrorPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 실패'),
          content: Text('아이디 또는 비밀번호가 맞지 않습니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image(
                height: 150,
                width: 100,
                image: NetworkImage('https://picsum.photos/200/300'),
              ),
            ),
            SizedBox(height: 20.0),
            FGTextField(controller: _emailController, text: "아이디"),
            SizedBox(height: 20.0),
            FGTextField(
                controller: _passwordController,
                text: '비밀번호',
                obscureText: true),
            if (_loginfn)
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: (Size(200, 40))),
                      onPressed: clickLogin,
                      child: Text('로그인'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: (Size(200, 40))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text('회원가입'),
                    )
                  ],
                ),
                SizedBox(height: 1.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('비밀번호를 잊으셨나요?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text('비밀번호 찾기'),
                  ),
                ]),
              ]),
            if (!_loginfn)
              Column(children: [
                SizedBox(height: 60),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      "로그인중입니다",
                      textAlign: TextAlign.center,
                    )),
                SizedBox(height: 60)
              ]),
          ],
        ),
      ),
    );
  }
}
