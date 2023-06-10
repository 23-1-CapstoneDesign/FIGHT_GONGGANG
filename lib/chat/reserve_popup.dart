
import 'package:fighting_gonggang/Layout/items.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;

class reservePopup extends StatefulWidget {
  final String chatRoomID;
  final String facName;
  const reservePopup({super.key, required this.chatRoomID,required this.facName});

  @override
  ReservePopupState createState() => ReservePopupState();
}

class ReservePopupState extends State<reservePopup> {
bool run=true;
List<Map<String,String>> dateList = [];
String _selectedTime="";
String _selectedDate="";

List<String> uniqueDatesList =[];
List<String> filteredTimes= [];
static final dbUrl = dotenv.env["MONGODB_URL"].toString();

@override
  void initState() {
    super.initState();
  getReservation();
  }


void getReservation() async {
  mongo.Db conn = await mongo.Db.create(dbUrl);
  await conn.open();
  mongo.DbCollection collection = conn.collection('facility');

  var find = await collection.find({"name": widget.facName,"isReserved":true}).toList();
  // print(find);
  for(int i=0;i<find.length;i++){
    if(mounted){
    setState(() {
      dateList.add({'date':find[i]['day'],'time':find[i]['time']});
    });


    }
  }
  Set<String> uniqueDates = <String>{};

  for (var data in dateList) {
    uniqueDates.add(data['date'].toString());
  }

  if(mounted){
    setState(() {
      uniqueDatesList= uniqueDates.toList();


    });

  }
  setDate(dateList[0]['date'].toString());
  conn.close();
}

void setDate(String date){
  if(mounted){
    setState(() {

      filteredTimes = dateList
          .where((data) => data['date'] == date)
          .map((data) => data['time'].toString())
          .toList();
      _selectedDate=date;
      _selectedTime=filteredTimes[0];
    });
  }

}


void resulve(){



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
            textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("날짜"),
              Text("시간")
            ],
          ),
          if(uniqueDatesList.isNotEmpty)
          Row(children: [ DropdownButton<String>(
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
                  });
                },
              ),
          ],)



        ],
      ),

      actions: [
        if(run)
          Align( child:
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.greenAccent), // 원하는 배경색으로 설정합니다.
                ),
                onPressed: () {


                  //todo 예약하기 기능 추가



                },
                child: const Text('예약하기'),
              ),
          ),
        if(!run)const Align(child:Text("업로드중...") )
      ],
    );
  }
}