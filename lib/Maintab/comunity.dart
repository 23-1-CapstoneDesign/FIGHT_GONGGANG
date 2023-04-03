import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';

import '../Layout/navbar.dart';
class ComunityPage extends StatelessWidget {

  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()  async {
      if (_lastPressedTime == null ||
          DateTime.now().difference(_lastPressedTime!) > Duration(seconds: 2)) {
        // 첫 번째 뒤로가기 버튼 클릭 시
        _lastPressedTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('한 번 더 누르면 종료됩니다.')),
        );
        return false; // 뒤로가기 버튼 막음
      } else {
        // 두 번째 뒤로가기 버튼 클릭 시
        SystemNavigator.pop(); // 앱을 종료시킴
        return true;
      }
    },
        child: Scaffold(
          // appBar: AppBar(
          //    title: Text('홈'),
          // ),
          body: Container(

            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '최신 글',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('글 제목 $index'),
                          subtitle: Text('작성자: 사용자 $index'),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: dashboard(),
          ),
        )
    );
  }


}

