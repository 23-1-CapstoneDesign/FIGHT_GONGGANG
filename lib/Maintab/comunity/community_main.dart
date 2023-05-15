import 'package:flutter/material.dart';
import 'community_post.dart';
import 'community_post_list.dart';
import 'community_youthPolicy_page.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('공강아 덤벼라 커뮤니티'),
      // ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: '전체 글 검색',
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 1.5,
                )),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildListItem(context, '자유 게시판'),
                Divider(),
                _buildListItem(context, '청년 정책'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String boardType = '자유 게시판';
          if (boardType == '자유 게시판') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostPage(boardType: '자유 게시판'),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        // 해당 게시판으로 이동하는 기능
        if (title == '청년 정책') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YouthPolicyPage(),
            ),
          );
        } else if (title == '자유 게시판') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardPostsPage(boardName: title),
            ),
          );
        }
      },
    );
  }
}
