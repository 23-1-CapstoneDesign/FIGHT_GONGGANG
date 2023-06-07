import 'package:fighting_gonggang/Maintab.dart';
import 'package:fighting_gonggang/Maintab/home/gallery_policy.dart';
import 'package:fighting_gonggang/Maintab/timetable/AddClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fighting_gonggang/Maintab/timetable/Timetable.dart';

import 'myParty.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// class HomePage extends StatelessWidget {
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var timeTable = TimeTable();
    return WillPopScope(
      onWillPop: () async {
        // 이전 페이지로 이동하지 않고 원하는 동작을 수행
        // 예를 들면 다이얼로그 표시 등
        return false; // true를 반환하면 이전 페이지로 이동
      },
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              timeTable,
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddClass()),
                    ).then((value) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MaintabPage()));
                    });
                  },
                  child: Text('시간표 등록하러 가기'),
                ),

                //
              ]),
              Divider(
                color: Colors.black,
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              Align(
                child: Text(
                  "참여중인 파티",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 200,
                child: Expanded(
                  child: MyParty(),
                ),
              ),
              Container(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                child: Column(
                  children: [
                    Align(
                      child: Text(
                        "청년 정책",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                        height: 200,
                        child:
                            Row(children: [Expanded(child: GalleryWidget())]))
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: dashboard(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
