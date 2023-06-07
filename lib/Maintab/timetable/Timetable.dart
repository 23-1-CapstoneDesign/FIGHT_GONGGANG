import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/*
메인 시간표영역
시간표 위젯을 가져오고, 버튼을 누르면 시간표 추가기능이 있는


 */

class TimeTable extends StatefulWidget {
  static GlobalKey<TimeTableState> myWidgetKey =
  GlobalKey<TimeTableState>();
  @override
  TimeTableState createState() => TimeTableState();
}

class TimeTableState extends State<TimeTable> {


  List<Appointment> _appointments = [];
  int _selectedDayIndex = -1;
  List<String> _classes = [];
  List<String> _startTimes = [];
  List<String> _endTimes = [];
  late CalendarDataSource _dataSource;
  static final dburl = dotenv.env["MONGO_URL"].toString();

  DateTime now = DateTime.now();





  @override
  void initState() {
    super.initState();
    _appointments = [];
    _dataSource = _getCalendarDataSource();

    getCurrentLocation().then((List<Appointment> value) {
      if(mounted) {
        setState(() {
          _appointments = value;
        });
      }
    });

  }




  Future<List<Appointment>> getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('class');
    var result =
        await collection.find({'user': prefs.getString('username')}).toList();

    List<Appointment> appointment = [];
    List<int> weekdays = [DateTime.monday];
    for (var i = 0; i < result.length; i++) {
      appointment.add(_getClassAppointments(result[i]['className'],
          result[i]['startTime'], result[i]['endTime'], result[i]['date']));
    }
    conn.close();
    return appointment;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: 400,
            height: 370,
            child: SfCalendar(
              view: CalendarView.week,
              timeSlotViewSettings: const TimeSlotViewSettings(
                  timeIntervalHeight: 30,
                  timeIntervalWidth: 10,

                  startHour: 09,
                  endHour: 18,
                  timeFormat: "hh:mm"),
              dataSource: _getCalendarDataSource(),
              headerDateFormat: 'yyyy년 M월',
            )),
      ],
    );
  }

  _DataSource _getCalendarDataSource() {
    return _DataSource(_appointments);
  }

  Appointment _getClassAppointments(
      String subjectName, String startTime, String endTime, String day) {
    List<int> startAt = [
      int.parse(startTime.split(":")[0]),
      int.parse(startTime.split(":")[1])
    ];
    List<int> endAt = [
      int.parse(endTime.split(":")[0]),
      int.parse(endTime.split(":")[1])
    ];
    // 메주 월요일마다 일정 추가
    DateTime startDate = DateTime.now();

    // 메모: 여기에서 원하는 일정을 만들 수 있습니다.
    // 예를 들면, 'eventName'과 'startTime', 'endTime' 등을 포함하는 Appointment 객체를 만들 수 있습니다.
    Appointment appointment = Appointment(
      subject: subjectName,
      startTime: DateTime(startDate.year, 3, 3,startAt[0],startAt[1],0),
      endTime: DateTime(startDate.year, 3, 3,
          endAt[0], endAt[1], 0),
      color: Colors.blue,
      recurrenceRule: 'FREQ=WEEKLY;BYDAY=${day};',
    );

    return appointment;

  }

  void _getPartyAppointments(
      String subjectName, String startTime, String endTime, String date) {
    List<int> startAt = [
      int.parse(startTime.split(":")[0]),
      int.parse(startTime.split(":")[1])
    ];
    List<int> endAt = [
      int.parse(endTime.split(":")[0]),
      int.parse(endTime.split(":")[1])
    ];
    // 메주 월요일마다 일정 추가
    DateTime startDate = DateTime.now();

    // 메모: 여기에서 원하는 일정을 만들 수 있습니다.
    // 예를 들면, 'eventName'과 'startTime', 'endTime' 등을 포함하는 Appointment 객체를 만들 수 있습니다.
    Appointment appointment = Appointment(
      subject: subjectName,
      startTime: DateTime(startDate.year, startDate.month, startDate.day),
      endTime: DateTime(startDate.year, startDate.month, startDate.day,
          endAt[0], endAt[1], 0),
      color: Colors.blue,
    );

    _appointments.add(appointment);
  }


  void getTempAppointments(
      String subjectName, String startTime, String endTime, String day) {
    List<int> startAt = [
      int.parse(startTime.split(":")[0]),
      int.parse(startTime.split(":")[1])
    ];
    List<int> endAt = [
      int.parse(endTime.split(":")[0]),
      int.parse(endTime.split(":")[1])
    ];

    DateTime startDate = DateTime.now();

    Appointment appointment = Appointment(
      subject: subjectName,
      startTime: DateTime(startDate.year, startDate.month, startDate.day),
      endTime: DateTime(startDate.year, startDate.month, startDate.day,
          endAt[0], endAt[1], 0),
      color: Colors.lightBlue,
      recurrenceRule: 'FREQ=WEEKLY;BYDAY=${day};',
    );

    setState(() {
      _appointments.add(appointment);
    });
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
