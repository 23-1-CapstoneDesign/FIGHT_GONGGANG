import 'package:fighting_gonggang/Maintab.dart';
import 'package:fighting_gonggang/Maintab/timetable/AddClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fighting_gonggang/Maintab/timetable/Timetable.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              timeTable,
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddClass()),
                    ).then((value) {


            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MaintabPage()));

                    });
                  },
                  child: Text('시간표 등록하러 가기'),
                )
              ]),
            ],
          ),
        ),
        drawer: Drawer(
          child: dashboard(),
        ),
      ),
    );
  }
}
