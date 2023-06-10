
import 'dart:typed_data';

import 'package:fighting_gonggang/chat/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:shared_preferences/shared_preferences.dart';


class Messages extends StatefulWidget {
  final String chatRoomID;

  const Messages({super.key, required this.chatRoomID});

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> {
  User? user;
  SharedPreferences? prefs;
  static final dburl = dotenv.env["MONGO_URL"].toString();
  Uint8List? image;

  ImageProvider? imageProvider;

  @override
  void initState() {

    super.initState();
    getUserInfo();
    getPrefs();
  }

  void getPrefs() async {
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        prefs = pref;
      });
    });
  }

  Future<void> getUserInfo() async {
    FirebaseAuth.instance.authStateChanges().first.then((value) {
      setState(() {
        user = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomID)
        .collection("chat")
        .orderBy('time', descending: true)
        .snapshots();

    return StreamBuilder(
      stream: usersStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<QueryDocumentSnapshot>? chatDocs = snapshot.data?.docs;

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs?.length,
          itemBuilder: (context, index) {

            return ChatBubbles(
              widget.chatRoomID,
              chatDocs?[index]['text'],
              chatDocs?[index]['userID'] ==
                  prefs?.getString('email').toString(),
              chatDocs?[index]['userName'],
            );

          },
        );
      },
    );
  }
}
