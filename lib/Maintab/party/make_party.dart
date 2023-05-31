import 'package:flutter/material.dart';

class MakePartyPage extends StatefulWidget {
  @override
  _MakePartyPageState createState() => _MakePartyPageState();
}

class _MakePartyPageState extends State<MakePartyPage> {
  String title = '';
  String tags = '';
  int maxMembers = 0;
  String description = '';

  void submitParty() {
    // 파티 DB연결
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파티 만들기'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: '파티 제목',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '태그 유형',
                hintText: '#운동 #공부',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  tags = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '원하는 모집 인원',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  maxMembers = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                labelText: '파티 소개글을 작성하세요',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: submitParty,
              child: Text('파티 만들기'),
            ),
          ],
        ),
      ),
    );
  }
}
