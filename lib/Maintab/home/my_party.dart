import 'dart:async';

import 'package:fighting_gonggang/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class MyParty extends StatefulWidget {
  const MyParty({super.key});

  @override
  MyPartyState createState() => MyPartyState();
}

class MyPartyState extends State<MyParty> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  var result;
  bool _dataLoaded = false;
  String nowTime = DateFormat('yyyy MM dd HH:mm').format(DateTime.now());

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {});
    getData();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    var list = await collection.find({
      'nowMembers': {
        '\$elemMatch': {'\$eq': prefs.getString('username')}
      }
    }).toList();

    if (mounted) {
      setState(() {
        result = list;

        result.sort((a, b) {
          if (a['reserve'] == null && b['reserve'] == null) {
            return 0;
          } else if (a['reserve'] == null) {
            return 1;
          } else if (b['reserve'] == null) {
            return -1;
          } else {
            return (a['reserve']['day'].toString() +
                    a['reserve']['time'].toString())
                .compareTo((b['reserve']['day'].toString() +
                    b['reserve']['time'].toString()));
          }
        });

        _dataLoaded = true;
      });
    }

    conn.close();
  }

  //모임 시작까지 남은 시간을 표시 하기위함
  int calculateMinuteDifference(String time1, String time2) {
    DateFormat format = DateFormat('yyyy MM dd HH:mm');
    // DateFormat format = DateFormat('yyyyMMddHH:mm');
    DateTime dateTime1 = format.parse(time1);
    DateTime dateTime2 = format.parse(time2);

    Duration difference = dateTime2.difference(dateTime1);

    int minuteDifference = difference.inMinutes;
    return minuteDifference;
  }

  @override
  Widget build(BuildContext context) {
    if (_dataLoaded && result!.isNotEmpty) {
      return ListView.builder(
        itemCount: result?.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          bool reserved = false;
          String text = "";
          if (result?[index]['reserve'] != null &&
              nowTime.compareTo(result?[index]['reserve']['day'] +
                      result?[index]['reserve']['time']) ==
                  -1) {
            reserved = true;
            int minute = calculateMinuteDifference(nowTime,
                '${result?[index]['reserve']['day']} ${result?[index]['reserve']['time']}');
            text = '${(minute % 60).toString()}분';
            if (minute >= 60) {
              minute = minute ~/ 60;
              text = '${(minute % 60).toString()}시간 $text';
              if (minute >= 24) {
                minute = minute ~/ 24;
                text = '${minute.toString()}일 $text';
              }
            }
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                        chatRoomName: result?[index]['name'],
                        chatRoomID: (result?[index]['_id'].toHexString()))),
              );
            },
            child: Container(
              width: 200,
              height: 200,
              // 카드의 너비를 조정하고 싶은 값으로 설정
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(0.0),
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
                  Text(
                    "파티명 : ${result?[index]['name']}",
                    style: GoogleFonts.gamjaFlower(
                        fontSize: 30, fontWeight: FontWeight.bold),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (reserved)
                    Text(
                      "       예약 현황\n예약시설: ${result?[index]['reserve']['fac']}\n모임까지: $text",
                      style: GoogleFonts.gamjaFlower(fontSize: 20),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          );

          // return null;
        },
      );
    } else if (_dataLoaded) {
      return const Align(child: Text("참여한 모임이 없습니다."));
    } else {
      return const Align(
        child: SizedBox(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
