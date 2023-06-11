import 'package:fighting_gonggang/Layout/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'community_main.dart';

class BoardPostDetailPage extends StatefulWidget {
  final String postId;

  const BoardPostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  _BoardPostDetailPageState createState() => _BoardPostDetailPageState();
}

class _BoardPostDetailPageState extends State<BoardPostDetailPage> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  String title = '';
  String username = '';
  String createdTime = '';
  String tags = '';
  String description = '';
  int likes = 0;
  bool _loaded = false;
  String myName = "";

  final _commentController = TextEditingController();

  @override
  void initState() {
    // 위젯의 상태가 처음 생성될 때 필요한 초기화 작업을 수행
    super.initState();
    loadBoardDetail();
  }

  bool isHexString(String value) {
    final RegExp hexPattern = RegExp(r'^[0-9A-Fa-f]+$');
    return hexPattern.hasMatch(value);
  }

  void deletePost() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('게시글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 아니오 버튼을 눌렀을 때
              },
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 예 버튼을 눌렀을 때
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // 게시글 삭제
      mongo.Db conn = await mongo.Db.create(dbUrl);
      await conn.open();
      mongo.DbCollection collection = conn.collection('community');

      // 게시글 삭제
      await collection
          .remove(mongo.where.id(mongo.ObjectId.parse(widget.postId)));
      print('게시글 삭제 완료');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommunityPage()),
      );
    }
  }

  void loadBoardDetail() async {
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('community');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 해당 게시물을 가져옴
    if (isHexString(widget.postId)) {
      final result = await collection
          .findOne(mongo.where.id(mongo.ObjectId.parse(widget.postId)));

      String formatDate(DateTime? dateTime) {
        if (dateTime == null) return '';

        final formattedDate =
            "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
        return formattedDate;
      }

      if (result != null && mounted) {
        setState(() {
          title = result['title'] ?? '';
          tags = result['tags']?.join(' ') ?? '';
          username = result['username'] ?? '';
          createdTime = formatDate(result['createdTime']);
          description = result['description'] ?? '';
          likes = result['likes'] ?? 0;
          myName = prefs.getString('username').toString();
          _loaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(50),
              child: Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              color: Colors.green,
              height: 5,
              thickness: 0.5,
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    createdTime,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 70),
                  if (username == myName)
                    ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        deletePost();
                      },
                      child: Text('삭제'),
                    ),
                  SizedBox(width: 6),
                  if (username == myName)
                    ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Text('수정'),
                    ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child:
                        LikeButton(initialCount: likes, postId: widget.postId),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  tags,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(

                children: [
                  Expanded(child:FGTextField(controller: _commentController, text: "댓글 작성하기"),
                  ),
    ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('댓글\n쓰기'),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
          color: Colors.white,
          child: const Align(
            child: SizedBox(
              child: CircularProgressIndicator(),
            ),
          ));
    }
  }
}

class LikeButton extends StatefulWidget {
  final int initialCount;
  final String postId;

  const LikeButton({Key? key, this.initialCount = 0, required this.postId})
      : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  int _count = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _count++;
      } else {
        if (_count > 0) {
          _count--;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleLike,
      child: Row(
        children: [
          Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : null),
          const SizedBox(width: 4),
          Text('$_count',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isLiked ? Colors.red : null)),
        ],
      ),
    );
  }
}
