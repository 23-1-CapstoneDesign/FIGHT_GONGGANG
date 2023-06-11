import 'package:fighting_gonggang/Layout/items.dart';
import 'package:fighting_gonggang/Maintab/mypage/image_upload_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:convert';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  String? profileImage;

  String email = '';
  String name = '';
  String nickname = '';
  Uint8List? image;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromMongodb();
  }

  void showUploadPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageUploadPopup(email);
      },
    ).then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            image = base64Decode(value);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            image = null;
          });
        }
      }
    });
  }

  void fetchDataFromMongodb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');

    final result =
        await collection.findOne({"email": prefs.getString('email')});
    if (mounted) {
      setState(() {
        email = result!['email'];
        name = result['username'];
        nickname = result['nickname'];
        image = (result['profile'] != null
            ? (base64Decode(result['profile']))
            : null);
        _loaded = true;
        // await image.writeAsBytes(base64Decode(result!['profile']!=null?base64Decode(result!['profile']):''));
      });
    }
    conn.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return WillPopScope(
        onWillPop: () async {
          // 이전 페이지로 이동하지 않고 원하는 동작을 수행
          // 예를 들면 다이얼로그 표시 등
          return false; // true를 반환하면 이전 페이지로 이동
        },
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: <Widget>[
                if (email != '')
                  Row(
                    children: [
                      Column(
                        children: [
                          const Text('프로필이미지',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            width: 150,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8.0),
                              image: (image != null)
                                  ? DecorationImage(
                                      image: MemoryImage(image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: (image != null)
                                  ? null
                                  : Colors.grey, // 기본 배경색
                            ),
                            child: (image != null)
                                ? null
                                : const Icon(Icons.person,
                                    color: Colors.white), // 기본 아이콘
                          ),
                          RawMaterialButton(
                              fillColor: Colors.green,
                              textStyle: const TextStyle(fontSize: 10),
                              onPressed: () {
                                showUploadPopup(context);
                              },
                              child: const Text('프로필 이미지 변경'))
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          FGRoundTextField(
                            text: "이메일: $email@sunmoon.ac.kr",
                            height: 50.0,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FGRoundTextField(text: "   이름: $name"),
                          const SizedBox(
                            height: 10,
                          ),
                          FGRoundTextField(text: "닉네임: $nickname"),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: RawMaterialButton(
                                  fillColor: Colors.green,
                                  textStyle: const TextStyle(fontSize: 10),
                                  onPressed: () {},
                                  child: const Text('개인 정보 변경'))),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                if (email == '')
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text("정보 가져오는 중")],
                  )
              ],
            ),
          ),
          drawer: const Drawer(
            child: Dashboard(),
          ),
        ),
      );
    } else {
      return WillPopScope(
          onWillPop: () async {
            // 이전 페이지로 이동하지 않고 원하는 동작을 수행
            // 예를 들면 다이얼로그 표시 등
            return false; // true를 반환하면 이전 페이지로 이동
          },
          child: Container(
              color: Colors.white,
              child: const Align(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                ),
              )));
    }
  }
}
