import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fighting_gonggang/Maintab/comunity/community_post.dart';
import 'package:fighting_gonggang/Maintab/comunity/community_post_detail.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Post {
  final String title;
  final String tag;
  final String? description;
  final DateTime createdTime;
  final String? postId;
  final String? id;

  Post({
    required this.title,
    required this.tag,
    required this.description,
    required this.createdTime,
    required this.postId,
    this.id,
  });
}

class CommunityPage extends StatefulWidget {
  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String? selectedPostId;
  static final dburl = dotenv.env["MONGODB_URL"].toString();
  List<Post> posts = [];
  bool _running = false;
  final List<String> _sortType = [
    '제목순↑',
    '제목순↓',
    '오래된 순',
    '최신 생성순',
  ];
  String _selectedType = "최신 생성순";

  @override
  void initState() {
    super.initState();
    loadCommunity();
  }

  void loadCommunity() async {
    if (mounted) {
      setState(() {
        _running = true;
      });
    }
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    // DB insert 부분
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('community');

    var communityList = await collection.find().toList();
    List<Post> tempPost = [];
    for (int i = 0; i < communityList.length; i++) {
      List<String> tags = List<String>.from(communityList[i]['tags']);
      String tagsString = tags.join(' ');
      String id = communityList[i]['_id'].toString();
      tempPost.add(Post(
        title: communityList[i]['title'],
        tag: tagsString,
        createdTime: communityList[i]['createdTime'],
        description: communityList[i]['description'],
        postId: id,
      ));
    }
    if (mounted) {
      setState(() {
        posts = tempPost;
        _running = false;
      });
    }
    sortPosts();
    conn.close();
  }

  String searchText = '';

  List<Post> get filteredPosts {
    return posts.where((post) {
      final partyNameLower = post.title.toLowerCase();
      final tagLower = post.tag.toLowerCase();
      final searchLower = searchText.toLowerCase();
      return partyNameLower.contains(searchLower) ||
          tagLower.contains(searchLower);
    }).toList();
  }

  // void showPartyDetails(BuildContext context, Post post) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return PartyDetailsPopup(
  //         partyName: post.partyName,
  //         tag: [post.tag],
  //         currentMembers: post.currentMembersCount,
  //         totalMembers: post.totalMembers,
  //         description: post.description,
  //       );
  //     },
  //   ).then((value) {
  //     if (value != null && value) {
  //       enterParty(post);
  //     }
  //   });
  // }

  void sortPosts() {
    if (mounted) {
      setState(() {
        if (_selectedType == _sortType[0]) {
          //이름순
          posts.sort((a, b) {
            return a.title.compareTo(b.title);
          });
        } else if (_selectedType == _sortType[1]) {
          //이름 역순
          posts.sort((a, b) {
            return b.title.compareTo(a.title);
          });
        } else if (_selectedType == _sortType[2]) {
          //날짜순
          posts.sort((a, b) {
            return a.createdTime.compareTo(b.createdTime);
          });
        } else if (_selectedType == _sortType[3]) {
          //날짜 역순
          posts.sort((a, b) {
            return b.createdTime.compareTo(a.createdTime);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // 이전 페이지로 이동하지 않고 원하는 동작을 수행
      // 예를 들면 다이얼로그 표시 등
      return false; // true를 반환하면 이전 페이지로 이동
    },
    child: Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    searchText = value;
                  });
                }
              },
              decoration: const InputDecoration(
                hintText: '검색',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("정렬방식 : ", style: TextStyle(fontSize: 15)),
                  DropdownButton<String>(
                    value: _selectedType,
                    items: _sortType.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue.toString();
                      });
                      sortPosts();
                    },
                  ),
                ],
              ),
              Row(children: [
                IconButton(
                    onPressed: () {
                      loadCommunity();
                    },
                    icon: const Icon(Icons.refresh)),
                SizedBox(
                  width: 20,
                ),
              ]),
            ],
          ),
          if (!_running)
            if (posts.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(post.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                post.tag,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                post.description != null &&
                                        post.description!.length > 20
                                    ? '${post.description!.substring(0, 20)}...'
                                    : post.description ?? '',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 15,
                              ) // Added null check and fallback value
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BoardPostDetailPage(
                                    postId: '6484640049bfe6afee8f644b'),
                              ),
                            );
                          },
                        ),
                        Divider(
                          color: Colors.grey,
                          height: 10,
                          thickness: 0.5,
                        ),
                      ],
                    );
                  },
                ),
              ),
          if (posts.isEmpty && !_running)
            Expanded(
                child: Align(
              child: Text("게시글이 없습니다."),
            )),
          if (_running)
            const Align(
              child: SizedBox(
                child: CircularProgressIndicator(),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => PostPage()))
                        .then((value) {
                      loadCommunity();
                    });
                  },
                  backgroundColor: Colors.lightGreen,
                  child: Icon(Icons.add)),
            ],
          )
        ],
      ),
    )
    );
  }
}
