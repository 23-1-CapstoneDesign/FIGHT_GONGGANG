import 'package:fighting_gonggang/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyParty extends StatefulWidget {
  MyParty();

  @override
  _MyPartyState createState() => _MyPartyState();
}

class _MyPartyState extends State<MyParty> {

  static final dburl = dotenv.env["MONGO_URL"].toString();
  List<Map<String, dynamic>>? result = null;
  bool _dataloaded = false;

  @override
  void initState() {
    getData();
  }




  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');

    collection
        .find(   { 'nowMembers': {
    '\$elemMatch': {'\$eq': prefs.getString('username')}
    }})
        .toList()
        .then((list) {
      if (mounted) {
        setState(() {
          result = list;
          _dataloaded = true;
        });
      }
    });
  }

  Future<void> _launchUrl(Uri url) async {
    canLaunchUrl(url).then((value) async{
      if(value)
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: result?.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        if (_dataloaded)
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(chatRoomName: result?[index]['name'],chatRoomID: (result?[index]['_id'].toHexString()))),
              );
            },
            child: Container(
              width: 200,
              // 카드의 너비를 조정하고 싶은 값으로 설정
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text("파티명 : ${result?[index]['name']}"),

                ],
              ),
            ),
          );
      },
    );
  }
}
