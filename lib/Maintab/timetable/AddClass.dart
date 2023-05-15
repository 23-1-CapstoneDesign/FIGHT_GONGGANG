import 'package:flutter/material.dart';
import 'package:cupertino_date_textbox/cupertino_date_textbox.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fighting_gonggang/Layout/items.dart';
import 'package:fighting_gonggang/dbconfig/db.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*


 */

class AddClass extends StatefulWidget {
  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {

  static final dburl = dotenv.env["MONGO_URL"].toString();
  DateTime _selectedTime = DateTime.now();
  int _selectedDayIndex = -1;
  List<String> _daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
  List<String> _hours = [];
  List<String> _minutes = [];
  late Database db;
  String selectedValue = "항목 1"; // 선택한 항목을 저장할 변수
  final _classController = TextEditingController();
  final _professorController = TextEditingController();

  int times = 0;
  List<String> _selectedDay = [];
  List<String> _selectedStartHours = [];
  List<String> _selectedStartMinutes = [];
  List<String> _selectedEndHours = [];
  List<String> _selectedEndMinutes = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 24; i++) {
      _hours.add(i.toString().padLeft(2, "0"));
    }
    for (var i = 0; i < 60; i += 5) {
      _minutes.add(i.toString().padLeft(2, "0"));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text("시간표 추가")),
        body: Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.end, // 위젯을 우측에 정렬
              children: [
                FGButton(
                  text: "취소",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 0),
                FGButton(
                    text: "완료",
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      // DB insert 부분
                      mongo.Db conn = await mongo.Db.create(dburl);
                      await conn.open();
                      mongo.DbCollection collection = conn.collection('class');
                      List<String> startTimes = [];
                      List<String> endTimes = [];
                      bool verification = true;
                      for (int i = 0; i < times; i++) {
                        startTimes.add(
                            "${_selectedStartHours[i]}:${_selectedStartMinutes[i]}");
                        endTimes.add(
                            "${_selectedEndHours[i]}:${_selectedEndMinutes[i]}");
                          if(startTimes[i].compareTo(endTimes[i])!=-1){
                            verification=false;
                          }
                      }
                      if(times==0){
                        Fluttertoast.showToast(msg: "시간을 추가해 시간을 입력해 주세요",  toastLength: Toast.LENGTH_SHORT,  gravity: ToastGravity.BOTTOM, );

                      }
                      else if(verification) {
                        for (int i = 0; i < _selectedDay.length; i++) {
                          var result = await collection.insert({
                            'user': prefs.getString('username'),
                            'className': _classController.text,
                            'date': _selectedDay[i],
                            'startTime':
                            "${_selectedStartHours[i]}:${_selectedStartMinutes[i]}",
                            'endTime':
                            "${_selectedEndHours[i]}:${_selectedEndMinutes[i]}",
                          });
                        }
                        Navigator.of(context).pop();
                      }
                      else{
                        Fluttertoast.showToast(msg: "시작 시간이 끝나는 시간보다 빨라야 합니다.",  toastLength: Toast.LENGTH_SHORT,);

                      }

                      //
                    }),
                SizedBox(width: 0),
              ]),
          FGTextField(controller: _classController, text: "강의명"),
          SizedBox(height: 20.0),
          FGTextField(controller: _professorController, text: "교수명"),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  times += 1;
                  _selectedDay.add("월");
                  _selectedStartHours.add("09");
                  _selectedStartMinutes.add("00");
                  _selectedEndHours.add("09");
                  _selectedEndMinutes.add("30");
                });
              },
              child: Text("시간 추가")),
          Expanded(
            child: ListView.builder(
              itemCount: times,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("요일:"),
                      DropdownButton<String>(
                        value: _selectedDay[index],
                        items: _daysOfWeek.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDay[index] = newValue.toString();
                          });
                        },
                      ),
                      Text("시작 시간:"),
                      DropdownButton<String>(
                        value: _selectedStartHours[index],
                        items: _hours.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedStartHours[index] = newValue.toString();
                          });
                        },
                      ),
                      Text(":"),
                      DropdownButton<String>(
                        value: _selectedStartMinutes[index],
                        items: _minutes.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedStartMinutes[index] = newValue.toString();
                          });
                        },
                      ),
                      Text("종료 시간:"),
                      DropdownButton<String>(
                        value: _selectedEndHours[index],
                        items: _hours.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEndHours[index] = newValue.toString();
                          });
                        },
                      ),
                      Text(":"),
                      DropdownButton<String>(
                        value: _selectedEndMinutes[index],
                        items: _minutes.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEndMinutes[index] = newValue.toString();
                          });
                        },
                      ),
                    ]);
              },
            ),
          ),
        ]));
  }
}
