import 'dart:convert';
import 'dart:typed_data';

import 'package:fighting_gonggang/chat/message.dart';
import 'package:fighting_gonggang/chat/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ChatScreen extends StatefulWidget {
  final String chatRoomID;
  final String chatRoomName;

  const ChatScreen({super.key, required this.chatRoomID, required this.chatRoomName});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class Clients {
  String username;
  Uint8List? profile;

  Clients({required this.username, this.profile});
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  List<Clients> users = [];

  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  late AnimationController _animationController;
  bool _isDrawerOpen = true;
  Uint8List? image;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    getCurrentUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void getCurrentUsers() async {
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    var query = {"_id": mongo.ObjectId.fromHexString(widget.chatRoomID)};


    var result = await collection.findOne(query);

    for (int i = 0; i < result?['nowMembers'].length; i++) {

      mongo.DbCollection collection = conn.collection('users');

      var user =
          await collection.findOne({"username": result?['nowMembers'][i]});

      if (mounted) {
        setState(() {


          if (user?['profile'] == null) {
            users.add(Clients(username: user?['username']));
          } else {

            users.add(Clients(
                username: user?['username'],
                profile: (base64Decode(user!['profile']))));
          }
        });
      }
    }
    conn.close();

    // users=List<String>.from(result?['nowMembers']);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("파티명 : ${widget.chatRoomName}"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              _toggleDrawer();
              // Navigator.pop(context);
            },
          )
        ],
      ),
      body: Stack(children: [
        Container(
          color: const Color.fromRGBO(0, 0, 100, 0.1),
          child: Column(
            children: [
              Container(
                color: const Color.fromRGBO(0, 0, 100, 0.3),
                height: 80,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // 수평 스크롤을 위해 설정
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (true) {
                      return GestureDetector(
                        onTap: () {
                          // 카드를 클릭했을 때 실행되는 코드
                        },
                        child: Container(
                          width: 80,
                          height: 60,
                          // 카드의 너비를 조정하고 싶은 값으로 설정
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              CircleAvatar(
                                backgroundImage: (users[index].profile != null)
                                    ? MemoryImage(users[index].profile!)
                                    : null,
                                child: (users[index].profile != null)
                                    ? null
                                    : const Icon(Icons.person, color: Colors.white),
                              ),
                              Text(
                                users[index].username,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: Messages(chatRoomID: widget.chatRoomID),
              ),
              NewMessage(chatRoomID: widget.chatRoomID),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            _isDrawerOpen ? -200 : 0,
            0,
            0,
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isDrawerOpen = false;
              });
            },
            child: Container(
              width: _isDrawerOpen ? 0.0 : double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            _isDrawerOpen ? screenSize.width : screenSize.width - 200,
            0.0,
            0.0,
          ),
          child: Container(
            width: 200.0,
            height: double.infinity,
            color: Colors.white,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    // Home 메뉴 클릭 시 원하는 동작 수행
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Settings 메뉴 클릭 시 원하는 동작 수행
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
