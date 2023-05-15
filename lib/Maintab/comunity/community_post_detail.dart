import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 임시 데이터
final List<Map<String, dynamic>> _boardData = [
  {'title': '게시글 1', 'author': '작성자 1', 'date': '2023-04-26', 'likes': 0},
  {'title': '게시글 2', 'author': '작성자 2', 'date': '2023-04-25', 'likes': 0},
  {'title': '게시글 3', 'author': '작성자 3', 'date': '2023-04-24', 'likes': 0},
  {'title': '게시글 4', 'author': '작성자 4', 'date': '2023-04-23', 'likes': 0},
  {'title': '게시글 5', 'author': '작성자 5', 'date': '2023-04-22', 'likes': 0},
].cast<Map<String, dynamic>>();

class LikeButton extends StatefulWidget {
  final int initialCount;
  final int postId;

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
        // 현재 게시글의 좋아요 수 증가
        _boardData[widget.postId - 1]['likes']++;
        _count++;
      } else {
        // 현재 게시글의 좋아요 수 감소
        if (_boardData[widget.postId - 1]['likes'] > 0) {
          _boardData[widget.postId - 1]['likes']--;
          _count--;
        }
      }
      _isLiked ? Colors.red : null;
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

// 게시글 상세 페이지
class BoardPostDetailPage extends StatelessWidget {
  final String boardName;
  final int postId;

  const BoardPostDetailPage(
      {Key? key, required this.boardName, required this.postId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final post = _boardData[postId - 1];
    return Scaffold(
      appBar: AppBar(
        title: Text(boardName),
      ),
      body: Column(
        children: [
          // 제목
          Container(
            margin: EdgeInsets.all(16),
            child: Text(
              post['title'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // 작성자, 작성일자
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.person, size: 16),
                SizedBox(width: 8),
                Text(post['author'] ?? ''),
                SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 8),
                Text(post['date'] ?? ''),
              ],
            ),
          ),
          // 좋아요 아이콘
          Container(
            margin: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LikeButton(postId: postId),
                SizedBox(width: 8),
                Text('${_boardData[postId - 1]['likes'].toString()}'),
              ],
            ),
          ),

          // 게시글 내용
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(16),
                child: Text(
                  '게시글 $postId의 내용입니다.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          // 댓글쓰기 기능
          Container(
            margin: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                SystemChannels.textInput.invokeMethod('TextInput.show');
              },
              child: Text('댓글쓰기'),
            ),
          ),
        ],
      ),
    );
  }
}
