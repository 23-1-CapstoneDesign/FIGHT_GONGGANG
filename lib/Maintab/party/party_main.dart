import 'package:fighting_gonggang/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fighting_gonggang/Maintab/party/party_popup.dart';
import 'package:fighting_gonggang/Maintab/party/make_party.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Post {
  final String id;
  final String partyName;
  final String tag;
  final int currentMembersCount;
  final List<String> currentMembers;
  final int totalMembers;
  final String? description;
  final DateTime createdTime;

  Post({
    required this.id,
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
  const PartyPage({super.key});


  @override
  PartyPageState createState() => PartyPageState();
}

class PartyPageState extends State<PartyPage> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  List<Post> posts = [];
  bool _running = false;
  final List<String> _sortType = [
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
    super.initState();
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
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');

    var partyList = await collection.find().toList();
    List<Post> tempPost = [];
    for (int i = 0; i < partyList.length; i++) {
      if (partyList[i]['maxMembers'] != partyList[i]['nowMembers'].length &&
          !List<String>.from(partyList[i]['nowMembers'])
              .contains(prefs.getString('username'))) {
        tempPost.add(Post(
            id: partyList[i]['_id'].toHexString(),
            partyName: partyList[i]['name'],
            currentMembersCount: partyList[i]['nowMembers'].length,
            currentMembers: List<String>.from(partyList[i]['nowMembers']),
            tag: partyList[i]['tags'],
            totalMembers: partyList[i]['maxMembers'],
            createdTime: partyList[i]['createdTime'],
            description: partyList[i]['description']));
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

  void enterParty(Post post) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // DB insert 부분
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    final query={      "name":post.partyName,
      "createdTime":post.createdTime};
    final document = await collection.findOne(query);

    if (document != null) {

      document['nowMembers'].add(prefs.getString('username')); // 새로운 데이터 추가


      // document['nowMembers'].removeWhere((element) => element == 'dataToRemove'); // 데이터 삭제

      await collection.replaceOne(query,document);

      Fluttertoast.showToast(
        msg: "${post.partyName}에 참여하였습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      conn.close();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(chatRoomName: post.partyName,chatRoomID: post.id)),
      );
    }
    conn.close();

    // (result?[index]['_id'].toHexString())



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



      if (value!=null&&value) {
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
            margin: const EdgeInsets.all(10),
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
                  const Text("정렬방식 : ", style: TextStyle(fontSize: 15)),
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
                const SizedBox(
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
            const Expanded(
                child: Align(
              child: Text("참여 할 수 있는 파티가 없습니다."),
             )
            ),
          if (_running)
            const Expanded(
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
                                builder: (context) => const MakePartyPage()))
                        .then((value) {
                      loadParty();
                    });
                  },
                  backgroundColor: Colors.lightGreen,
                  child: const Icon(Icons.add)),
            ],
          )
        ],
      ),
    );
  }
}
