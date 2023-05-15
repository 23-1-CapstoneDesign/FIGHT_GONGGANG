import 'package:flutter/material.dart';
import 'dart:core';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  int _currentIndex = 0;
  String _checkPassword = "";
  String _checkRepassword = "";
  bool _passwordIsVisible = false;
  bool _RepasswordIsVisible = false;

  bool _checkString(String value) {
    final RegExp alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');

    return alphaNumeric.hasMatch(value);
  }

  bool _isRightPass(String value) {
    final RegExp numericRegex = RegExp(r'\d+');
    final RegExp alphaRegex = RegExp(r'[a-zA-Z]+');

    return numericRegex.hasMatch(value) && alphaRegex.hasMatch(value);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름*'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일*'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호*'),
              onChanged: ((input) {
                if (input.length < 8 || input.length > 12) {
                  setState(() {
                    _checkPassword = "비밀번호는 8자이상 12자 이하여야 해용";
                    _passwordIsVisible = true;
                  });
                } else if (!_checkString(input)) {
                  setState(() {
                    _checkPassword = "비밀번호는 영어와 숫자로만 이루어져야해용";
                    _passwordIsVisible = true;
                  });
                } else if (!_isRightPass(input)) {
                  setState(() {
                    _checkPassword = "비밀번호는 영어,숫자가 섞여있어야 해용";
                    _passwordIsVisible = true;
                  });
                } else {
                  setState(() {
                    _checkPassword = "";
                    _passwordIsVisible = false;
                  });
                }
              }),
            ),
            Visibility(
                visible: _passwordIsVisible,
                child: Text(_checkPassword,
                    style: TextStyle(
                      color: Colors.red,
                    ))),
            TextField(
              controller: _repasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호 재확인*'),
              onChanged: (String input) {
                if (_passwordController.text != input) {
                  setState(() {
                    _checkRepassword = "비밀번호가 일치하지 않습니다.";
                    _RepasswordIsVisible = true;
                  });
                } else {
                  setState(() {
                    _checkRepassword = "";
                    _RepasswordIsVisible = false;
                  });
                }
              },
            ),
            Visibility(
                visible: _RepasswordIsVisible,
                child: Text(_checkRepassword,
                    style: TextStyle(
                      color: Colors.red,
                    ))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text;
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  // 회원가입 로직 처리
                  print('');
                },
                child: Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
