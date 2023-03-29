import 'package:flutter/material.dart';
import 'dart:core';
import 'package:mysql1/mysql1.dart';
class SignupPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _departmentController =TextEditingController();
  final _studentnumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _styleController = TextEditingController();
  int _currentIndex = 0;



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
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: '학과'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
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
