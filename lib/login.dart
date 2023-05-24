import 'package:fighting_gonggang/Maintab.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SignUp.dart';
import 'package:fighting_gonggang/Layout/items.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final autoLogin = prefs.getBool('autoLogin');

    if (autoLogin != null && autoLogin) {
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      _login(username!, password!);
    }
  }

  void clickLogin() async {
    // final username = _usernameController.text;
    // final password = _passwordController.text;
    //todo 로그인 적용전까지만 사용
    const username = "asdf";
    const password = "1234444";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_autoLogin) {
      prefs.setString('username', username);
      prefs.setString('password', password);
      prefs.setBool('autoLogin', true);
      prefs.setBool('isLogin', true);
    }
    prefs.setString('username', username);
    _login(username, password);
  }

  // 로그인 처리
  void _login(String id, String password) async {
    // 로그인 처리 이 들어가야할 구간

    //true: 로그인 성공 false: 로그인 실패시 작동할 문구
    if (true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MaintabPage()),
      );
    } else {
      showLoginErrorPopup();
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
            FGTextField(controller: _usernameController, text: "아이디"),
            SizedBox(height: 20.0),
            FGTextField(
                controller: _passwordController,
                text: '비밀번호',
                obscureText: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: (Size(200, 40))),
                  onPressed: clickLogin,
                  child: Text('로그인'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: (Size(200, 40))),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Checkbox(
                  value: _autoLogin,
                  onChanged: (value) {
                    setState(() {
                      _autoLogin = value!;
                    });
                  },
                ),
                Text('자동 로그인'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
