import 'package:fighting_gonggang/Maintab/comunity/community_post_edit.dart';
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
  static final dburl = dotenv.env["MONGODB_URL"].toString();

  String title = '';
  String username = '';
  String createdTime = '';
  String tags = '';
  String description = '';
  int likes = 0;
  String myName="";
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
      mongo.Db conn = await mongo.Db.create(dburl);
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
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('community');

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
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (result != null) {
        setState(() {
          myName=prefs.getString('username')!;
          title = result['title'] ?? '';
          tags = result['tags']?.join(' ') ?? '';
          username = result['username'] ?? '';
          createdTime = formatDate(result['createdTime']);
          description = result['description'] ?? '';
          likes = result['likes'] ?? 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(40),
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
              children: [
                Icon(Icons.person, size: 20),
                SizedBox(width: 8),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 8),
                Text(
                  createdTime,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Spacer(),

                SizedBox(width: 70),
                if(myName==username)
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    deletePost();
                  },
                  child: Text('삭제'),
                ),
                SizedBox(width: 6),
                if(username==myName)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditPostPage(
                                postId: widget.postId,
                                initialTitle: title,
                                initialDescription: description,
                                initialTags: tags)));
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
                  child: LikeButton(initialCount: likes, postId: widget.postId),
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
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '댓글을 입력하세요',
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        ),
                        maxLines: 1,
                        // 댓글 입력값을 저장하고 처리하는
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 댓글 작성 클릭시 댓글을 저장하는
                      },
                      child: Text('작성'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
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
          SizedBox(width: 4),
          Text('$_count',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isLiked ? Colors.red : null)),
        ],
      ),
    );
  }
}
