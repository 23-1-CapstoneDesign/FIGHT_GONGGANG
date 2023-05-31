import 'dart:convert';
import 'dart:typed_data';

import 'package:fighting_gonggang/chat/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
class Messages extends StatefulWidget {


  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  User? user;
  SharedPreferences? prefs;
  static final dburl = dotenv.env["MONGO_URL"].toString();
  Uint8List? image;

  ImageProvider? imageProvider;
  @override
  void initState() {
    // TODO: implement initState
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

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('chat')
      .doc("sdf")
      .collection("chat")
      .orderBy('time', descending: true)
      .snapshots();


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _usersStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<QueryDocumentSnapshot>? chatDocs = snapshot.data?.docs;



        return ListView.builder(
          reverse: true,
          itemCount: chatDocs?.length,
          itemBuilder: (context, index) {
            return ChatBubbles(
                chatDocs?[index]['text'],
                chatDocs?[index]['userID'] ==
                    prefs?.getString('email').toString(),
                chatDocs?[index]['userName'],



            )            ;
          },
        );
      },
    );
  }
}