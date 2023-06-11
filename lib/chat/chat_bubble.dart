import 'dart:convert';
import 'dart:typed_data';

import 'package:fighting_gonggang/chat/reserve_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ChatBubbles extends StatefulWidget {
  const ChatBubbles(this.chatRoomID, this.message, this.isMe, this.userName, {super.key});

  final String chatRoomID;
  final String message;
  final String userName;
  final bool isMe;

  @override
  ChatBubblesState createState() => ChatBubblesState();
}

class ChatBubblesState extends State<ChatBubbles> {
  Uint8List? image;
  static final dburl = dotenv.env["MONGO_URL"].toString();

  @override
  void initState() {
    super.initState();
    if (widget.isMe) {
      myProfile();
    } else {
      fetchDataFromMongodb();
    }
  }

  void myProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        image = (prefs.getString('profile') != null
            ? (base64Decode(prefs.getString('profile').toString()))
            : null);
      });
    }
  }

  void fetchDataFromMongodb() async {

    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');
    final result = await collection.findOne({"username": widget.userName});
    if (mounted) {
      setState(() {
        image = (result!['profile'] != null
            ? (base64Decode(result['profile']))
            : null);
        // image = null;
        // await image.writeAsBytes(base64Decode(result!['profile']!=null?base64Decode(result!['profile']):''));
      });
    }
    conn.close();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (widget.isMe)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 80, 0),
              child: ChatBubble(
                clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                alignment: Alignment.topRight,
                margin: const EdgeInsets.only(top: 20),
                backGroundColor: const Color.fromRGBO(0, 255, 0, 0.15),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Text(
                    widget.message,
                    style: GoogleFonts.gamjaFlower(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 25),
                  ),
                ),
              ),
            ),
          if (!widget.isMe)
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 10, 0, 0),
              child: ChatBubble(
                clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                backGroundColor: const Color.fromRGBO(100, 100, 0, 0.2),
                margin: const EdgeInsets.only(top: 20),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (widget.userName == "reserve")
                        TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ReservePopup(chatRoomID: widget.chatRoomID, facName: widget.message);
                                  });

                            },
                            child: Text(
                              widget.message,
                              style: GoogleFonts.gamjaFlower(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromRGBO(0, 0, 200, 0.8)),
                            ))
                      else if(widget.userName == "reserve")const Text("notice")
                      else
                        Text(
                          widget.message,
                          style: GoogleFonts.gamjaFlower(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(255, 255, 255, 1)),
                        ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
      Positioned(
          top: 0,
          right: widget.isMe ? 5 : null,
          left: widget.isMe ? null : 5,
          child: Column(children: [
            CircleAvatar(
              backgroundImage: (image != null) ? MemoryImage(image!) : null,
              backgroundColor: const Color.fromRGBO(0, 0, 100, 0.1),
              child: (image != null)
                  ? null
                  : const Icon(Icons.person, color: Colors.white),
            ),
            Text(
              widget.userName,
              style: GoogleFonts.gamjaFlower(color: Colors.black),
            ),
          ])),
    ]);
  }
}
