import 'package:fighting_gonggang/Maintab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registration_page.dart';



class LoginPage extends StatefulWidget {



  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe=false;
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
      if (username != null && password != null) {
        _usernameController.text = username;
        _passwordController.text = password;
        setState(() {
          _rememberMe = true;
          _autoLogin = true;
        });
        _login();
      }
    }
  }

  // 로그인 처리
  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    // 로그인 처리 로직
    if (_rememberMe) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      prefs.setString('password', password);
      prefs.setBool('autoLogin', true);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MaintabPage()),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                ),
                Text('로그인 정보 기억하기'),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _autoLogin,
                  onChanged: (value) {
                    setState(() {
                      _autoLogin = value!;
                      if (_autoLogin) {
                        _rememberMe = true;
                      }
                    });
                  },
                ),
                Text('자동 로그인'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _login,
                child: Text('로그인'),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
