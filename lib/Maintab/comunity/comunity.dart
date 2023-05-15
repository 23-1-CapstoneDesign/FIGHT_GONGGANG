import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';

import '../../Layout/navbar.dart';
class ComunityPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {
      // 이전 페이지로 이동하지 않고 원하는 동작을 수행
      // 예를 들면 다이얼로그 표시 등
      return false; // true를 반환하면 이전 페이지로 이동
    },child:Scaffold(
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
        ),
    );
  }


}

