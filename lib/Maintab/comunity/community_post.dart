import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  static final dburl = dotenv.env["MONGO_URL"].toString();

  late String _username;

  String title = '';
  String tags = "";
  String content = '';
  File? _imageFile; // 선택된 이미지 파일

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedBoard;

  bool _running = false;

  void initState() {
    super.initState();
    // 사용자 정보 가져오기
    _getUserInfo();
  }

  void _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  // 이미지 선택 및 미리보기 처리
  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery, // 갤러리에서 이미지 가져오기
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void submitCommunity() async {
    if (RegExp(r'^\s*$').hasMatch(title) || title.isEmpty) {
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
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('community');
    try {
      collection.insertOne({
        "title": title,
        "tags": tags.split(' '), // 공백으로 구분
        "description": content,
        "createdTime": DateTime.now(),
        "username": _username,
      });
      Fluttertoast.showToast(
        msg: "게시글 생성이 완료되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pop(context);
    } on Exception {
      if (mounted) {
        setState(() {
          _running = false;
        });
      }
    }
    conn.close();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 18),
            TextField(
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted)
                  setState(() {
                    title = value;
                  });
              },
            ),
            SizedBox(height: 30),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    content = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: '태그(공백으로 구분)',
                hintText: '#정보글 #메롱 #배고파',
                hintStyle: TextStyle(
                  color: Colors.grey[400], // 힌트 텍스트 색상 설정
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    tags = value;
                  });
                }
              },
            ),
            // 이미지 첨부 버튼
            // 어떻게 해야하지?
            InkWell(
              onTap: _getImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text(
                      '이미지 ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 선택된 이미지 미리보기
            if (_imageFile != null) ...[
              SizedBox(height: 16),
              Container(
                height: 200,
                child: Image.file(_imageFile!),
              ),
            ],
            //////////////////////////
            SizedBox(height: 16),
            if (!_running)
              ElevatedButton(
                onPressed: submitCommunity,
                child: Text('등록'),
              ),
            if (_running) Text("게시글 생성 중"),
          ],
        ),
      ),
    );
  }
}
