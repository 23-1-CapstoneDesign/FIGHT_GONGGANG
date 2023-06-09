import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class MakePartyPage extends StatefulWidget {
  const MakePartyPage({super.key});

  @override
  MakePartyPageState createState() => MakePartyPageState();
}

class MakePartyPageState extends State<MakePartyPage> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  String title = '';
  String tags = '';
  int maxMembers = 2;
  String description = '';

  int _selectedMaxMembers = 0;

  final _tagController = TextEditingController();

  bool _running = false;

  void submitParty() async {
    // 파티 DB연결

  if (RegExp(r'^\s*$').hasMatch(title)||title.isEmpty) {
    Fluttertoast.showToast(
      msg: "제목을 입력해주세요",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
      return;
    }

    if (mounted) {
      setState(() {
        _running = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // DB insert 부분
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    try {
      collection.insertOne({
        "name": title,
        "tags": tags,
        "maxMembers": maxMembers,
        "description": description,
        "nowMembers": [prefs.getString('username')],
        "createdTime": DateTime.now(),
      });

      Fluttertoast.showToast(
        msg: "파티가 생성되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      conn.close();
      Navigator.pop(context);
    } on Exception {
      if (mounted) {
        setState(() {
          _running = false;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파티 만들기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: '파티 제목',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    title = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: '태그 유형',
                hintText: '#운동 #공부',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    tags = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black38,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  const Text("최대 참여 인원  :  "),
                  DropdownButton<int>(
                    value: _selectedMaxMembers,
                    items: List<DropdownMenuItem<int>>.generate(9, (index) {
                      int value = index + 2;

                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$value', style: const TextStyle(fontSize: 30)),
                      );
                    }),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        if (mounted) {
                          setState(() {
                            _selectedMaxMembers = newValue + 2;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '파티 소개글을 작성하세요',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    description = value;
                  });
                }
              },
            ),
            if (!_running)
              ElevatedButton(
                onPressed: submitParty,
                child: const Text('파티 만들기'),
              ),
            if (_running) const Text("파티생성중..."),
          ],
        ),
      ),
    );
  }
}
