import 'package:fighting_gonggang/Maintab/timetable/Timetable.dart';
import 'package:flutter/material.dart';
import 'package:fighting_gonggang/Layout/items.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*


 */

class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  AddClassState createState() => AddClassState();
}

class AddClassState extends State<AddClass> {
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  final List<String> _daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _daysOfWeekENG = [
    'MO',
    'TU',
    'WE',
    'TH',
    'FR',
    'SA',
    'SU'
  ];
  final List<String> _hours = [];
  final List<String> _minutes = [];
  String selectedValue = "항목 1"; // 선택한 항목을 저장할 변수
  final _classController = TextEditingController();
  final _professorController = TextEditingController();

  int times = 0;
  final List<String> _selectedDay = [];
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
        appBar: AppBar(title: const Text("시간표 추가")),
        body: Column(children: [
          const TimeTable(),
          Row(
              mainAxisAlignment: MainAxisAlignment.end, // 위젯을 우측에 정렬
              children: [
                FGRoundButton(
                  text: "취소",
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                ),
                const SizedBox(width: 0),
                FGRoundButton(
                    text: "완료",
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      // DB insert 부분
                      mongo.Db conn = await mongo.Db.create(dbUrl);
                      await conn.open();
                      mongo.DbCollection collection = conn.collection('class');
                      List<String> startTimes = [];
                      List<String> endTimes = [];

                      List<String> days = [];

                      bool verification1 = true;

                      bool verification3 = true;

                      for (int i = 0; i < times; i++) {
                        days.add(_daysOfWeekENG[
                            _daysOfWeek.indexOf(_selectedDay[i])]);

                        startTimes.add(
                            "${_selectedStartHours[i]}:${_selectedStartMinutes[i]}");
                        endTimes.add(
                            "${_selectedEndHours[i]}:${_selectedEndMinutes[i]}");
                        if (startTimes[i].compareTo(endTimes[i]) != -1) {
                          setState(() {
                            verification1 = false;
                          });
                        }

                        var finding = await collection.find({
                          '\$and': [
                            {
                              '\$or': [
                                {
                                  'startTime': {
                                    '\$gte': startTimes[i],
                                    '\$lte': endTimes[i],
                                  }
                                },
                                {
                                  'endTime': {
                                    '\$gte': startTimes[i],
                                    '\$lte': endTimes[i],
                                  }
                                },
                                {
                                  'startTime': {'\$lt': startTimes[i]},
                                  'endTime': {'\$gt': endTimes[i]},
                                },
                              ]
                            },
                            {
                              'user': prefs.getString('username'),
                              'date': days[i]
                            }
                          ]
                        }).toList();

                        if (finding.isNotEmpty) {
                          if(!mounted)return;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('등록 실패'),
                                content: Text('중복된 수업이 존재합니다\n중복된 수업:${finding[0]['className']}\n중복된 시간:${startTimes[i]}~${endTimes[i]}'),
                                actions: [
                                  TextButton(
                                      child: const Text('확인'),
                                      onPressed: () =>
                                          Navigator.pop(context, true)),
                                ],
                              );
                            },
                          );
                          conn.close();
                          return;
                        }
                      }

                      for (int i = 0; i < times; i++) {
                        for (int j = 0; j < times; j++) {
                          if (i != j && days[i] == days[j]) {
                            int res1 = startTimes[i].compareTo(startTimes[j]);
                            int res2 = startTimes[i].compareTo(endTimes[j]);
                            int res3 = endTimes[i].compareTo(startTimes[j]);
                            int res4 = endTimes[i].compareTo(endTimes[j]);
                            if (res1 <= 0 && res3 >= 0) {
                              setState(() {
                                verification3 = false;
                              });
                            } else if (res2 <= 0 && res4 >= 0) {
                              setState(() {
                                verification3 = false;
                              });
                            }
                          }
                        }
                      }

                      if (times == 0) {
                        Fluttertoast.showToast(
                          msg: "시간을 추가해 시간을 입력해 주세요",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      } else if (!verification1) {
                        Fluttertoast.showToast(
                          msg: "시작 시간이 끝나는 시간보다 빨라야 합니다.",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      } else if (!verification3) {
                        Fluttertoast.showToast(
                          msg: "중복된 시간",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      } else {
                        List<String> dates = [];
                        List<String> sTimes = [];
                        List<String> eTimes = [];

                        for (int i = 0; i < _selectedDay.length; i++) {
                          sTimes.add(
                              "${_selectedStartHours[i]}:${_selectedStartMinutes[i]}");
                          eTimes.add(
                              "${_selectedEndHours[i]}:${_selectedEndMinutes[i]}");
                        }

                        var data = {
                          'user': prefs.getString('username'),
                          'professor': _professorController.text,
                          'className': _classController.text,
                          'date': days,
                          'startTime': sTimes,
                          'endTime': eTimes,
                        };

                        var result = await collection.insert({
                          'user': prefs.getString('username'),
                          'professor': _professorController.text,
                          'className': _classController.text,
                          'date': days,
                          'startTime': sTimes,
                          'endTime': eTimes,
                        });
                        // for (int i = 0; i < _selectedDay.length; i++) {
                        //   await collection.insert({
                        //     'user': prefs.getString('username'),
                        //     'professor': _professorController.text,
                        //     'className': _classController.text,
                        //     'date': days[i],
                        //     'startTime':
                        //         "${_selectedStartHours[i]}:${_selectedStartMinutes[i]}",
                        //     'endTime':
                        //         "${_selectedEndHours[i]}:${_selectedEndMinutes[i]}",
                        //   });
                        // }
                        conn.close();
                        if (result.isNotEmpty) {
                          print(result);
                          print(result[0]);
                          Navigator.of(context).pop();
                        }
                      }
                      conn.close();
                    }),
                const SizedBox(width: 0),
              ]),
          FGTextField(
            controller: _classController,
            text: "강의명",
          ),
          const SizedBox(height: 20.0),
          FGTextField(
            controller: _professorController,
            text: "교수명",
          ),
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
              child: const Text("시간 추가")),
          Expanded(
            child: ListView.builder(
              itemCount: times,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("요일:"),
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
                      const Text("시작:"),
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
                      const Text(":"),
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
                      const Text("종료:"),
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
                      const Text(":"),
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
                      SizedBox(
                          width: 20,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDay.removeAt(index);
                                _selectedStartMinutes.removeAt(index);
                                _selectedStartHours.removeAt(index);
                                _selectedEndHours.removeAt(index);
                                _selectedEndMinutes.removeAt(index);
                                times -= 1;
                              });
                            },
                            icon: const Icon(Icons.delete),
                          ))
                    ]);
              },
            ),
          ),
        ]));
  }
}
