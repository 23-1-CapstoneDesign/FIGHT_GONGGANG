import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'community_main.dart';

class EditPostPage extends StatefulWidget {
  final String postId;
  final String initialTitle;
  final String initialDescription;
  final String initialTags;

  const EditPostPage({
    Key? key,
    required this.postId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialTags,
  });

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  static final dburl = dotenv.env["MONGODB_URL"].toString();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _tagsController = TextEditingController(
        text: widget.initialTags != null
            ? widget.initialTags!.split(' ').join(' ')
            : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  bool _running = false;

  void _updatePost() async {
    String updatedTitle = _titleController.text;
    String updatedDescription = _descriptionController.text;
    List<String> updatedTags = _tagsController.text.split(' ');

    if (RegExp(r'^\s*$').hasMatch(updatedTitle) || updatedTitle.isEmpty) {
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
    // DB insert 부분
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('community');
    try {
      collection.insertOne({
        "title": updatedTitle,
        "tags": updatedTags, // 공백으로 구분
        "description": updatedDescription,
        "createdTime": DateTime.now(),
      });
      // 기존 게시글 삭제
      await collection
          .remove(mongo.where.id(mongo.ObjectId.parse(widget.postId)));
      //await collection.remove(mongo.where.eq("_id", widget.postId));
      Fluttertoast.showToast(
        msg: "게시글 수정이 완료되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } on Exception {
      if (mounted) {
        setState(() {
          _running = false;
        });
      }
    }
    conn.close();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommunityPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 수정'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 18),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _descriptionController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
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
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updatePost,
              child: Text('수정'),
            ),
          ],
        ),
      ),
    );
  }
}
