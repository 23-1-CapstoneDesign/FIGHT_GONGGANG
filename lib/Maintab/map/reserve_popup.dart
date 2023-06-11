import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fighting_gonggang/Layout/items.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class ReservePopup extends StatefulWidget {
  final String facName;
  final String day;

  const ReservePopup({super.key, required this.facName, required this.day});

  @override
  ReservePopupState createState() => ReservePopupState();
}

class Reserve {
  final String fac;
  final String day;
  final String time;

  Reserve({required this.fac, required this.day, required this.time});
}

class ReservePopupState extends State<ReservePopup> {
  bool run = true;
  List<String> dateList = [];
  List<Map<String, dynamic>> partyList = [];

  String _selectedTime = "";
  String _selecetedParty = "";

  List<String> uniqueDatesList = [];
  List<String> filteredTimes = [];
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  bool _dataLoaded = false;
  bool _isReserved = false;


  String chatRoomID="";
  Reserve? reserve;

  @override
  void initState() {
    super.initState();
    getReservation();
  }

  void getReservation() async {
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('facility');

    print(widget.day);
    print(widget.facName);
    var find = await collection.find({
      "name": widget.facName,
      "isReserved": true,
      "day": widget.day
    }).toList();

    for (int i = 0; i < find.length; i++) {

      if (mounted) {
        setState(() {
          if(!dateList.contains(find[i]['time'])) {
            dateList.add(find[i]['time']);
          }
        });
      }

    }
    // print(dateList);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    collection = conn.collection('party');
    var list = await collection.find({
      'nowMembers': {
        '\$elemMatch': {'\$eq': prefs.getString('username')}
      }
    }).toList();

    if (mounted) {
      setState(() {
        partyList = list;
        _selecetedParty=list[0]['name'];
        chatRoomID=list[0]['_id'].toHexString();
        _selectedTime=dateList[0];
      });
      // print(partyList);
    }

    //todo party data가져오기
    // collection = conn.collection('party');
    // var query = {"_id": mongo.ObjectId.fromHexString("widget.chatRoomID")};
    // var partyData = await collection.findOne(query);
    // String nowTime = DateFormat('yyyyMMddHH:mm').format(DateTime.now());
    // if (partyData?['reserve'] != null &&
    //     nowTime.compareTo(
    //             partyData?['reserve']['day'] + partyData?['reserve']['time']) ==
    //         -1 &&
    //     mounted) {
    //   setState(() {
    //     _isReserved = true;
    //     reserve = Reserve(
    //         fac: partyData?['reserve']['fac'],
    //         day: partyData?['reserve']['day'],
    //         time: partyData?['reserve']['time']);
    //   });
    // }

    // Set<String> uniqueDates = <String>{};

    if (mounted) {
      setState(() {
        _dataLoaded=true;
      });
    }
    conn.close();
  }

  void updateReserve() async {
    if (mounted) {
      setState(() {
        run = false;
      });
    }
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    var query = {"_id": mongo.ObjectId.fromHexString(chatRoomID)};
    // var find=collection.findOne(query);
    var find = await collection.findOne(query);
    if (find?['reserve'] != null) {}
    var data = {
      "fac": widget.facName,
      "day": widget.day,
      "time": _selectedTime
    };

    // var modifier = mongo.ModifierBuilder().set('reserve', data);

    // var result = await collection.updateOne(query, modifier);

    FirebaseFirestore.instance
        .collection('chat')
        .doc(chatRoomID)
        .collection("chat")
        .add({
      'text': '${widget.facName} 이 ${widget.day} $_selectedTime 에 예약되었습니다. ',
      'time': Timestamp.now(),
      'userID': 'notice',
      'userName': 'notice',
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  DateTime addTime(String dateString, int i) {
    DateFormat format = DateFormat('HH:mm');
    DateTime dateTime = format.parse(dateString);
    dateTime = dateTime.add(Duration(minutes: i));
    return dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(),
        const SizedBox(),
        const Text("시설 예약하기"),
        FGRoundButton(
            text: "x",
            onPressed: () {
              Navigator.pop(context);
            },
            textStyle:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("파티"), Text("시간")],
          ),
          if (_dataLoaded)
            Row(
              children: [
                DropdownButton<String>(
                  value: _selecetedParty,
                  items: partyList.map((var item) {
                    return DropdownMenuItem<String>(
                      value: item['name'],
                      child: Text(item['name']),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selecetedParty = newValue.toString();
                      for (var ele in partyList) {

                        if(ele['name']==_selecetedParty){
                          print(ele);
                          chatRoomID=ele['_id'].toHexString();
                          print(chatRoomID);


                        }

                      }



                    });
                    // setDate(_selecetedParty);
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: _selectedTime,
                  items: dateList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTime = newValue.toString();
                    });
                  },
                ),
              ],
            )
          else
            CircularProgressIndicator(),
          if (_isReserved)
            Column(children: [
              Text(
                "이미 예약된 시설이 있습니다.\n",
                style: GoogleFonts.gamjaFlower(color: Colors.red),
              ),
              Align(
                child: Text(
                  "시설명:${reserve?.fac}\n날짜:${reserve?.day}\n시간:${reserve?.time}",
                  style: GoogleFonts.gamjaFlower(color: Colors.red),
                ),
              ),
            ]),
        ],
      ),
      actions: [
        if (run && _dataLoaded)
          Align(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.greenAccent), // 원하는 배경색으로 설정합니다.
              ),
              onPressed: () {
                updateReserve();
                //todo 예약하기 기능 추가
              },
              child: const Text('예약하기'),
            ),
          ),
        if (!run) const Align(child: Text("업로드중..."))
      ],
    );
  }
}
