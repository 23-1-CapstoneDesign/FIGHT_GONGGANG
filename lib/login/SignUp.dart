import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:core';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:fighting_gonggang/Layout/items.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _againPasswordController = TextEditingController();

  bool _nicknameCheck = false;
  String _checkPassword = "";
  String _checkAgainPassword = "";
  bool _passwordIsVisible = false;
  bool _againPasswordIsVisible = false;
  String _checked = "중복확인";

  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _nicknameNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _ckPasswordNode = FocusNode();
  bool nameFocused = false;
  bool emailFocused = false;
  bool passwordFocused = false;
  bool ckPasswordFocused = false;

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
    _nameNode.addListener(() {
      setState(() {
        nameFocused = _nameNode.hasFocus;
      });
    });
    _emailNode.addListener(() {
      setState(() {
        emailFocused = _emailNode.hasFocus;
      });
    });
    _passwordNode.addListener(() {
      setState(() {
        passwordFocused = _passwordNode.hasFocus;
      });
    });
    _ckPasswordNode.addListener(() {
      setState(() {
        ckPasswordFocused = _ckPasswordNode.hasFocus;
      });
    });
  }

  void nicknameCheck(String nickname) async {
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');

    var find = await collection.find({'nickname': nickname}).toList();
    RegExp pattern = RegExp(r'^[가-힣a-zA-Z0-9]{2,8}$');
    // pattern.hasMatch(nickname);

    if (find.isEmpty && pattern.hasMatch(nickname)) {
      setState(() {
        _nicknameCheck = true;
      });
    } else {
      setState(() {
        _nicknameCheck = false;
      });
    }
    conn.close();
  }

  // 파이어베이스 사용자 등록 함수
  Future<UserCredential?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '$email@sunmoon.ac.kr',
        password: password,
      );
      return userCredential;
    } catch (e) {
      // 등록 실패 처리
      return null;
    }
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // 비밀번호를 바이트로 변환
    var sha256Hash = sha256.convert(bytes); // SHA-256 해시 알고리즘 적용
    var hashedPassword = sha256Hash.toString(); // 해시값 반환
    return hashedPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FGTextField(controller: _nameController, text: "이름*"),
            const SizedBox(
              height: 10,
            ),
            FGTextField(
              controller: _nicknameController,
              text: "닉네임*",
              focusNode: _nicknameNode,
              onChanged: (str) {
                nicknameCheck(str);
              },
            ),
            Text(_nicknameCheck ? '사용가능' : '2-8글자사이의 한글,영어,숫자만 입력가능합니다.',
                style: TextStyle(
                  color: _nicknameCheck ? Colors.blue : Colors.red,
                )),
            const SizedBox(
              height: 10,
            ),
            Row(children: [
              Expanded(
                child: FGTextField(
                  text: "이메일*",
                  controller: _emailController,
                  focusNode: _emailNode,
                  onChanged: (val) {
                    setState(() {
                      _checked = "중복확인";
                    });
                  },
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  '@Sunmoon.ac.kr',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    String checkId = _emailController.text;
                    if (checkId.length < 4 || checkId.length > 12) {
                      Fluttertoast.showToast(
                        msg: "4글자 이상 12자 이하의 이메일만 사용가능합니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      mongo.Db conn = await mongo.Db.create(dbUrl);
                      await conn.open();
                      mongo.DbCollection collection = conn.collection('users');

                      var find =
                          await collection.find({'email': checkId}).toList();

                      if (find.isEmpty) {
                        setState(() {
                          _checked = "사용가능";
                        });
                      } else {
                        setState(() {
                          _checked = "사용불가";
                        });
                      }
                      conn.close();
                    }
                  },
                  child: Text(_checked))
            ]),
            const SizedBox(
              height: 10,
            ),
            if (emailFocused)

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  '',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            FGTextField(
                text: "비밀번호*",
                controller: _passwordController,
                obscureText: true,
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
                })),
            Visibility(
                visible: _passwordIsVisible,
                child: Text(_checkPassword,
                    style: const TextStyle(
                      color: Colors.red,
                    ))),
            const SizedBox(
              height: 10,
            ),
            FGTextField(
              text: "비밀번호 재확인*",
              controller: _againPasswordController,
              obscureText: true,
              onChanged: (String input) {
                if (_passwordController.text != input) {
                  setState(() {
                    _checkAgainPassword = "비밀번호가 일치하지 않습니다.";
                    _againPasswordIsVisible = true;
                  });
                } else {
                  setState(() {
                    _checkAgainPassword = "";
                    _againPasswordIsVisible = false;
                  });
                }
              },
            ),
            Visibility(
                visible: _againPasswordIsVisible,
                child: Text(_checkAgainPassword,
                    style: const TextStyle(
                      color: Colors.red,
                    ))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text;
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  final nickname = _nicknameController.text;
                  if (name.isEmpty || name.length > 15) {
                    Fluttertoast.showToast(
                      msg: "이름이 작성되지 않았습니다",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else if (_checked != "사용가능") {
                    Fluttertoast.showToast(
                      msg: "중복확인이 되지 않았습니다.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else if (_passwordController.text.isEmpty ||
                      _checkPassword != "") {
                    Fluttertoast.showToast(
                      msg: "비밀번호가 옳바르지 않습니다.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else if (_againPasswordController.text.isEmpty ||
                      _checkAgainPassword != "") {
                    Fluttertoast.showToast(
                      msg: "비밀번호 재확인이 완료되지 않았습니다.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    // 회원가입 로직 처리

                    mongo.Db conn = await mongo.Db.create(dbUrl);
                    await conn.open();
                    mongo.DbCollection collection = conn.collection('users');

                    UserCredential? userCredential =
                        await registerUser(email, password);

                    if (userCredential != null) {
                      try {
                        var result = await collection.insert({
                          'username': name,
                          'email': email,
                          'password': hashPassword(password),
                          'nickname': nickname
                        });

                        if (result['ok'] != 0) {
                          Fluttertoast.showToast(
                            msg: "등록에 실패했습니다.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          _checked = "중복확인";
                        } else {
                          conn.close();
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: e.toString(),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: "등록에 실패했습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                    conn.close();
                  }
                },
                child: const Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
