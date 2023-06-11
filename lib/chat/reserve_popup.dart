import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fighting_gonggang/Layout/items.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ReservePopup extends StatefulWidget {
  final String chatRoomID;
  final String facName;

  const ReservePopup(
      {super.key, required this.chatRoomID, required this.facName});

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
  List<Map<String, String>> dateList = [];

  String _selectedDate = "";
  String _selectedTime = "";
  String _selectedEnd = "";


  List<String> uniqueDatesList = [];
  List<String> filteredTimes = [];
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  bool _dataLoaded = false;
  bool _isReserved = false;

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

    var find = await collection
        .find({"name": widget.facName, "isReserved": true}).toList();
    // print(find);
    for (int i = 0; i < find.length; i++) {
      if (mounted) {
        setState(() {
          dateList.add({'date': find[i]['day'], 'time': find[i]['time']});
        });
      }
    }

    collection = conn.collection('party');
    var query = {"_id": mongo.ObjectId.fromHexString(widget.chatRoomID)};
    var partyData = await collection.findOne(query);
    String nowTime = DateFormat('yyyyMMddHH:mm').format(DateTime.now());
    if (partyData?['reserve'] != null &&
        nowTime.compareTo(
                partyData?['reserve']['day'] + partyData?['reserve']['time']) ==
            -1 &&
        mounted) {
      setState(() {
        _isReserved = true;
        reserve = Reserve(
            fac: partyData?['reserve']['fac'],
            day: partyData?['reserve']['day'],
            time: partyData?['reserve']['time']);
      });
    }

    Set<String> uniqueDates = <String>{};

    for (var data in dateList) {
      uniqueDates.add(data['date'].toString());
    }

    if (mounted) {
      setState(() {
        uniqueDatesList = uniqueDates.toList();
      });
    }
    if(dateList!=null) {
      setDate(dateList[0]['date'].toString());
    }
    else{
      if(mounted){
        setState(() {
          _dataLoaded = true;
        });
      }

    }
    conn.close();
  }

  void setDate(String date) {
    if (mounted) {
      setState(() {
        filteredTimes = dateList
            .where((data) => data['date'] == date)
            .map((data) => data['time'].toString())
            .toList();
        _selectedDate = date;
        _selectedTime = filteredTimes[0];
        _dataLoaded = true;
      });
    }
  }

  void updateReserve() async {
    if(mounted) {
      setState(() {
      run=false;
    });
    }
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');
    var query = {"_id": mongo.ObjectId.fromHexString(widget.chatRoomID)};
    // var find=collection.findOne(query);
    var find = await collection.findOne(query);
    if (find?['reserve'] != null) {}
    var data = {
      "fac": widget.facName,
      "day": _selectedDate,
      "time": _selectedTime
    };

    var modifier = mongo.ModifierBuilder().set('reserve', data);

    var result = await collection.updateOne(query, modifier);

    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomID)
        .collection("chat")
        .add({
      'text': '${widget.facName} 을(를) ${_selectedDate} $_selectedTime 에 예약되었습니다. ',
      'time': Timestamp.now(),
      'userID': 'notice',
      'userName': 'notice',
    });


    if (!mounted) return;
    Navigator.pop(context);
  }

  DateTime addTime(String dateString,int i) {
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
            children: [Text("날짜"), Text("시간")],
          ),
          if (_dataLoaded)
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedDate,
                  items: uniqueDatesList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDate = newValue.toString();
                    });
                    setDate(_selectedDate);
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: _selectedTime,
                  items: filteredTimes.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTime = newValue.toString();
                      _selectedDate = DateFormat('HH:mm').format(addTime(_selectedTime, 30));
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
