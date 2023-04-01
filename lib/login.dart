import 'package:fighting_gonggang/Maintab.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SignUp.dart';
import 'dbconfig/dbconnect.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autoLogin = false;

  final db = Database.instance;
  int a= 1+2;
  //sql 결과를 담기 위한 mapList
  List<Map<String, dynamic>> _results = [];

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
          _autoLogin = true;
        });
        _login();
      }
    }
  }
  Future<List<Map<String, dynamic>>> test() async {
    final results = await db.executeQuery("SELECT * FROM board");
    return results.map((r) => r.fields).toList();

    // Future<String> value= result.then((val){
    //   return val.toString();
    // }) ;
    //
    // return value;
  }
  // 로그인 처리
  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    // 로그인 처리 로직
    if (_autoLogin) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      prefs.setString('password', password);
      prefs.setBool('autoLogin', true);
      prefs.setBool('isLogin',true);
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
            SizedBox(height: 10.0),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: (Size(200, 40))),
                  onPressed: _login,
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
            FutureBuilder<List<Map<String,dynamic>>>(
              future: test(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    _results = snapshot.data;
                    return ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(_results[index]['name']),
                          subtitle: Text(_results[index]['email']),
                        );
                      },
                    );
                  } else {
                    return Text('No Results Found.');
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
