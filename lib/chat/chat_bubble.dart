import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ChatBubbles extends StatefulWidget {
  const ChatBubbles(this.message, this.isMe, this.userName);

  final String message;
  final String userName;
  final bool isMe;

  @override
  _ChatBubblesState createState() => _ChatBubblesState();
}

class _ChatBubblesState extends State<ChatBubbles> {
  Uint8List? image;
  static final dburl = dotenv.env["MONGO_URL"].toString();

  @override
  void initState() {

    fetchDataFromMongoDB();

  }

  void fetchDataFromMongoDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');

    final result =
        await collection.findOne({"email": prefs.getString('email')});
    if (mounted) {
      setState(() {
        image = (result!['profile'] != null
            ? (base64Decode(result!['profile']))
            : null);

        // await image.writeAsBytes(base64Decode(result!['profile']!=null?base64Decode(result!['profile']):''));
      });
    }
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
              padding: const EdgeInsets.fromLTRB(0, 10, 45, 0),
              child: ChatBubble(
                clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 20),
                backGroundColor: Colors.blue,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        widget.message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!widget.isMe)
            Padding(
              padding: const EdgeInsets.fromLTRB(45, 10, 0, 0),
              child: ChatBubble(
                clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                backGroundColor: Color(0xffE7E7ED),
                margin: EdgeInsets.only(top: 20),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.message,
                        style: TextStyle(color: Colors.black),
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
        child: CircleAvatar(
          backgroundImage: (image != null)
              ? MemoryImage(image!):null,
          child: (image != null)
              ? null
              : Icon(Icons.person, color: Colors.white),
        ),
      ),
    ]);
  }
}
