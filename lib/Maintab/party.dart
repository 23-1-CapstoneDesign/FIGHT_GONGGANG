import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';

import '../Layout/navbar.dart';

class PartyPage extends StatelessWidget {
  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        dense: true,
                        visualDensity: VisualDensity(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        leading: Icon(Icons.person),
                        isThreeLine: true,
                        title: Text('${index + 1} 파티 제목'),
                        subtitle: Text('태그 #활발 #소통 #적극'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // 특정 파티를 선택하면 입장 팝업을 띄움
                          showDialog(
                              context: context,
                              barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text("이 파티에 들어가시겠습니까?"),
                                  insetPadding:
                                      const EdgeInsets.fromLTRB(0, 80, 0, 80),
                                  actions: [
                                    TextButton(
                                      child: const Text('입장'),
                                      // 선택된 파티 스크린으로 이동
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('취소'), // 팝업 창 닫힘
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }),
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
    );
  }
}
