import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'AddClass.dart';

/*
메인 시간표영역
시간표 위젯을 가져오고, 버튼을 누르면 시간표 추가기능이 있는


 */

class TimeTable extends StatefulWidget {
  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  List<Appointment> _appointments = [];
  int _selectedDayIndex = -1;
  List<String> _classes = [];
  List<String> _startTimes = [];
  List<String> _endTimes = [];
  late CalendarDataSource _dataSource;
  static final dburl = dotenv.env["MONGO_URL"].toString();

  @override
  void initState(){
    super.initState();
    _dataSource = _getCalendarDataSource();

  }
  Future<List<Map<String, dynamic>>> getCurrentLocation() async {
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('class');
    var result = await collection.find({'user': "asdf"}).toList();

    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder(
            future: getCurrentLocation(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
              }
              //error가 발생하게 될 경우 반환하게 되는 부분
              else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              }
              // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
              else {
                // return const Text("들어왔어요");
                //todo Data추가부분
                final List<Map<String, dynamic>> data = snapshot.data;

                List<Appointment> recurringEvents = [];
                DateTime startDate = DateTime(DateTime.now().year, 3, 1);
                DateTime endDate = DateTime(DateTime.now().year,6,20);
                List<int> weekdays = [DateTime.monday];
                // RecurrenceProperties recurrenceProperties = RecurrenceProperties(
                //   startDate: startDate,
                //   endDate: endDate,
                //   recurrenceType: RecurrenceType.weekly, // 매주 반복
                //   interval: 1, // 1주일마다 반복
                //   weekDays: <WeekDays>[WeekDays.monday]);
                _addAppointment();


                return Expanded(
                  child: SfCalendar(
                    view: CalendarView.week,
                    dataSource: _getCalendarDataSource(),
                  ),
                );
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              _addAppointment();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClass()),
              );
            },
            child: Text('Add Appointment'),

          ),
        ],
      ),
    );
  }

  _DataSource _getCalendarDataSource() {
    return _DataSource(_appointments);
  }

  void _addAppointment() {

      DateTime now = DateTime.now();
      Appointment newAppointment = Appointment(
        startTime: now,
        endTime: now.add(Duration(hours: 5)),
        subject: 'New Appointment',
        color: Colors.orange,
      );
      _appointments.add(newAppointment);
    }

}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
