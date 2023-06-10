
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class NewMessage extends StatefulWidget {
  final String chatRoomID;

  const NewMessage({super.key, required this.chatRoomID});

  @override
  NewMessageState createState() => NewMessageState();
}

class NewMessageState extends State<NewMessage> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  String? image;
  List<String> notice = ["!원화관", "!본관", "!자연관", "!인문관", "!학생회관", "!all", "!전부"];

  List<Map<String, dynamic>> names = [];
  List<String> name = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
  }

  final _controller = TextEditingController();
  var _userEnterMessage = '';

  void _sendMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusScope.of(context).unfocus();


    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomID)
        .collection("chat")
        .add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'userID': prefs.getString('email'),
      'userName': prefs.getString('username'),
    });

    if (notice.contains(_userEnterMessage)) {

      setFacility(_userEnterMessage.replaceAll("!", ""));



      if(name.isNotEmpty) {

        for(int i=0;i<name.length;i++) {
          FirebaseFirestore.instance
              .collection('chat')
              .doc(widget.chatRoomID)
              .collection("chat")
              .add({
            'text': name[i],
            'time': Timestamp.now(),
            'userID': "notice",
            'userName': "notice",
            'show': prefs.getString('username')
          });
        }
      }
    }

    _controller.clear();
  }

  void getName() async {
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('facility');

    final pipeline = [
      {
        '\$group': {
          '_id': '\$facility',
          'names': {'\$addToSet': '\$name'},
        },
      },
      {
        '\$project': {
          '_id': 0,
          'facility': '\$_id',
          'names': 1,
        },
      },
    ];
    List<Map<String, dynamic>> result =
        await collection.aggregateToStream(pipeline).toList();

    if (mounted) {
      setState(() {
        names = result;
      });

      // names['values'].map((dynamic value) => value as String));
    }
    conn.close();
  }

  void setFacility(String facility) async {
    int index = names.indexWhere((element) => element['facility'] == facility);

    if (index != -1 && mounted) {
      setState(() {
        name = List<String>.from(names[index]['names']);
      });
    } else if (mounted) {
      setState(() {
        name = [];
      });
    }

    if (facility == "all" || facility == "전부") {
      for (int i = 0; i < names.length; i++) {
        if (mounted) {
          setState(() {
            name.addAll(List<String>.from(names[i]['names']));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: const InputDecoration(labelText: '메시지'),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
