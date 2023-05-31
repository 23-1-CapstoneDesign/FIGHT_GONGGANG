import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
class NewMessage extends StatefulWidget {

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  static final dburl = dotenv.env["MONGO_URL"].toString();
  String? image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  final _controller = TextEditingController();
  var _userEnterMessage = '';
  void _sendMessage()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusScope.of(context).unfocus();
    // final userData = await FirebaseFirestore.instance.collection('user')
    //     .doc(user!.uid).get();
    User? user= await FirebaseAuth.instance.authStateChanges().first;
    FirebaseFirestore.instance.collection('chat').doc("sdf").collection("chat").add({

      'text' : _userEnterMessage,
      'time' : Timestamp.now(),
      'userID' : prefs.getString('email'),
      'userName' : prefs.getString('username'),

    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}