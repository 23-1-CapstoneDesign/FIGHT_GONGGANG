import 'package:flutter/material.dart';
import 'community_post_detail.dart';
import 'community_post.dart';

class BoardPostsPage extends StatefulWidget {
  final String boardName;

  const BoardPostsPage({Key? key, required this.boardName}) : super(key: key);

  @override
  _BoardPostsPageState createState() => _BoardPostsPageState();
}

// 게시글 목록 페이지
// 추후 데이터 베이스와 연동
class _BoardPostsPageState extends State<BoardPostsPage> {
  final TextEditingController searchController = TextEditingController();
  final List<String> searchResult = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
      ),
      body: Column(
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.93,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // 검색 버튼을 누를 때 처리할 내용
                      final query = searchController.text;
                      if (query.isEmpty) {
                        // 검색어가 비어있다면 모든 게시글을 보여줍니다.
                        searchResult.clear();
                      } else {
                        // 검색어가 비어있지 않다면, 게시글 제목에서 검색어를 찾습니다.
                        searchResult.clear();
                        for (int i = 0; i < 10; i++) {
                          final title = '게시글 ${i + 1}';
                          if (title.contains(query)) {
                            searchResult.add('${i + 1}');
                          }
                        }
                      }
                      // 검색 결과를 반영합니다.
                      setState(() {});
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              )),
          Expanded(
            child: ListView.builder(
              itemCount: searchResult.isEmpty ? 10 : searchResult.length,
              itemBuilder: (context, index) {
                if (searchResult.isEmpty) {
                  return ListTile(
                    title: Text('게시글 ${index + 1}  #태그 자리'),
                    subtitle: Text('게시글 ${index + 1}의 내용입니다.'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardPostDetailPage(
                            boardName: widget.boardName,
                            postId: index + 1,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  final postId = int.parse(searchResult[index]);
                  return ListTile(
                    title: Text('게시글 $postId'),
                    subtitle: Text('게시글 $postId의 내용입니다.'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardPostDetailPage(
                            boardName: widget.boardName,
                            postId: postId,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 게시판 목록 페이지
class BoardListPage extends StatelessWidget {
  const BoardListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시판 목록'),
      ),
      body: ListView(
        children: <Widget>[
          _buildListItem(
              context, '자유 게시판', () => _showBoardPosts(context, '자유 게시판')),
          Divider(),
          _buildListItem(
              context, '중고 거래', () => _showBoardPosts(context, '중고 거래')),
          Divider(),
          _buildListItem(
              context, '청년 정책', () => _showBoardPosts(context, '청년 정책')),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.arrow_right),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBoardPosts(BuildContext context, String boardName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardPostsPage(boardName: boardName),
      ),
    );
  }
}
