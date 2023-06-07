import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import '../../Layout/navbar.dart';

import 'party_popup.dart';
import 'make_party.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Post {
  final String partyName;
  final String tag;
  final int currentMembersCount;
  final List<String> currentMembers;
  final int totalMembers;
  final String? description;
  final DateTime createdTime;

  Post({
    required this.partyName,
    required this.tag,
    required this.currentMembersCount,
    required this.currentMembers,
    required this.totalMembers,
    required this.createdTime,
    this.description,
  });
}

class PartyPage extends StatefulWidget {
  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간

  @override
  _PartyPageState createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  static final dburl = dotenv.env["MONGO_URL"].toString();
  List<Post> posts = [];
  bool _running = false;
  List<String> _sortType = [
    '이름순↑',
    '이름순↓',
    '오래된 순',
    '최신 생성순',
    '참여인원↑',
    '참여인원↓'
  ];
  String _selectedType = "이름순↑";

  @override
  void initState() {
    loadParty();
  }

  void loadParty() async {
    if (mounted) {
      setState(() {
        _running = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // DB insert 부분
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');

    var party_list = await collection.find().toList();
    List<Post> tempPost = [];
    for (int i = 0; i < party_list.length; i++) {
      if (party_list[i]['maxMembers'] != party_list[i]['nowMembers'].length &&
          !List<String>.from(party_list[i]['nowMembers'])
              .contains(prefs.getString('username'))) {
        tempPost.add(Post(
            partyName: party_list[i]['name'],
            currentMembersCount: party_list[i]['nowMembers'].length,
            currentMembers: List<String>.from(party_list[i]['nowMembers']),
            tag: party_list[i]['tags'],
            totalMembers: party_list[i]['maxMembers'],
            createdTime: party_list[i]['createdTime'],
            description: party_list[i]['description']));
      }
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

  void enterParty(Post post) {




  }

  String searchText = '';

  List<Post> get filteredPosts {
    return posts.where((post) {
      final partyNameLower = post.partyName.toLowerCase();
      final tagLower = post.tag.toLowerCase();
      final searchLower = searchText.toLowerCase();
      return partyNameLower.contains(searchLower) ||
          tagLower.contains(searchLower);
    }).toList();
  }

  void showPartyDetails(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PartyDetailsPopup(
          partyName: post.partyName,
          tag: [post.tag],
          currentMembers: post.currentMembersCount,
          totalMembers: post.totalMembers,
          description: post.description,
        );
      },
    ).then((value) {
      if (value) {
        enterParty(post);
      }
    });
  }

  void sortPosts() {
    if (mounted) {
      setState(() {
        if (_selectedType == _sortType[0]) {
          //이름순
          posts.sort((a, b) {
            return a.partyName.compareTo(b.partyName);
          });
        } else if (_selectedType == _sortType[1]) {
          //이름 역순
          posts.sort((a, b) {
            return b.partyName.compareTo(a.partyName);
          });
        } else if (_selectedType == _sortType[2]) {
          //이름 역순
          posts.sort((a, b) {
            return a.createdTime.compareTo(b.createdTime);
          });
        } else if (_selectedType == _sortType[3]) {
          //이름 역순
          posts.sort((a, b) {
            return b.createdTime.compareTo(a.createdTime);
          });
        } else if (_selectedType == _sortType[4]) {
          //이름 역순
          posts.sort((a, b) {
            return b.currentMembersCount.compareTo(a.currentMembersCount);
          });
        } else if (_selectedType == _sortType[5]) {
          //이름 역순
          posts.sort((a, b) {
            return a.currentMembersCount.compareTo(b.currentMembersCount);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                if (mounted)
                  setState(() {
                    searchText = value;
                  });
              },
              decoration: InputDecoration(
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
                      loadParty();
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
                    return ListTile(
                      title: Text(post.partyName),
                      subtitle: Text(
                          '${post.tag != "" ? '태그: ${post.tag} | ' : ''}현재 인원 : ${post.currentMembersCount}/${post.totalMembers}'),
                      // 게시글 내용을 표시
                      onTap: () {
                        showPartyDetails(context, post);
                      },
                    );
                  },
                ),
              ),
          if (posts.isEmpty && !_running)
            Expanded(
                child: Align(
              child: Text("참여 할 수 있는 파티가 없습니다."),
            )),
          if (_running)
            Expanded(
              child: Align(
                child: Text("데이터를 불러오는 중입니다."),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MakePartyPage()))
                        .then((value) {
                      loadParty();
                    });
                  },
                  backgroundColor: Colors.lightGreen,
                  child: Icon(Icons.add)),
            ],
          )
        ],
      ),
    );
  }
}
