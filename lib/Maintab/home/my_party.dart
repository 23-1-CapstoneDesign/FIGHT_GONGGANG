import 'package:fighting_gonggang/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';


class MyParty extends StatefulWidget {
  const MyParty({super.key});

  @override
  MyPartyState createState() => MyPartyState();
}

class MyPartyState extends State<MyParty> {

  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  List<Map<String, dynamic>>? result;
  bool _dataLoaded = false;
  @override
  void initState() {
    super.initState();
    print(result?.length);
    getData();

  }




  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    var list=await collection.find({'nowMembers':{    '\$elemMatch': {'\$eq': prefs.getString('username')}}}).toList();
    if (mounted) {
      setState(() {
        result = list;
        _dataLoaded=true;
      });
    }

    conn.close();
  }



  @override
  Widget build(BuildContext context) {
    if(_dataLoaded && result!.isNotEmpty) {
      return ListView.builder(
      itemCount: result?.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(chatRoomName: result?[index]['name'],chatRoomID: (result?[index]['_id'].toHexString()))),
              );
            },
            child: Container(
              width: 200,
              height: 10,
              // 카드의 너비를 조정하고 싶은 값으로 설정
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
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

        // return null;
      },
    );
    } else if(_dataLoaded){
      return Align(child:Text("참여한 모임이 없습니다."));

    }else {
      return const Align(child: SizedBox(

        child: CircularProgressIndicator(),
      ),);
    }
  }
}
