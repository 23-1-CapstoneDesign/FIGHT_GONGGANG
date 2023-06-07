import 'package:fighting_gonggang/chat/message.dart';
import 'package:fighting_gonggang/chat/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatefulWidget {
  String chatRoomID;
  String chatRoomName;
  ChatScreen({required this.chatRoomID,required this.chatRoomName});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.chatRoomID);
    return Scaffold(
      appBar: AppBar(
        title: Text("파티명 : ${widget.chatRoomName}"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Messages(chatRoomID: widget.chatRoomID),
            ),
            NewMessage(chatRoomID: widget.chatRoomID),
          ],
        ),
      ),

    );
  }
}