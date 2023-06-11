import 'package:fighting_gonggang/Maintab/timetable/time_popup.dart';
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
  const TimeTable({super.key});

  @override
  TimeTableState createState() => TimeTableState();
}

class TimeTableState extends State<TimeTable> {
  List<Appointment> _appointments = [];

  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  final List<Color> colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.cyan,
    Colors.yellowAccent,
    Colors.orangeAccent,
    Colors.amberAccent,
    Colors.pink,
    Colors.tealAccent
  ];
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
    _getPartyAppointments();
  }

  void getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dbUrl);

    await conn.open();
    mongo.DbCollection collection = conn.collection('class');
    var result =
        await collection.find({'user': prefs.getString('username')}).toList();

    List<Appointment> appointment = [];
    for (var i = 0; i < result.length; i++) {
      for (var j = 0; j < result[i]['startTime'].length; j++) {
        appointment.add(_getClassAppointments(
            result[i]['className'],
            result[i]['startTime'][j],
            result[i]['endTime'][j],
            result[i]['date'][j],
            colors[i]));
      }
    }
    conn.close();
    setState(() {
      _appointments = appointment;
    });
  }

  void showDetailPopUp(String name, List<dynamic>? appointments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimeDetailsPopup(
          name: name,
          appointments: appointments,
        );
      },
    ).then((value) {
      if (value != null && value) {
        // enterParty(post);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          onLongPress: (detail) {
            showDetailPopUp(
                detail.appointments?[0].subject, detail.appointments);
          },
        ));
  }

  _DataSource _getCalendarDataSource() {
    return _DataSource(_appointments);
  }

  Appointment _getClassAppointments(String subjectName, String startTime,
      String endTime, String day, Color color) {
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
      startTime: DateTime(startDate.year, 3, 3, startAt[0], startAt[1], 0),
      endTime: DateTime(startDate.year, 3, 3, endAt[0], endAt[1], 0),
      color: color,
      notes: "",
      recurrenceRule: 'FREQ=WEEKLY;BYDAY=$day;',
    );

    return appointment;
  }


  void _getPartyAppointments() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('party');

    var list = await collection.find({
      'nowMembers': {
        '\$elemMatch': {'\$eq': prefs.getString('username')}
      }
    }).toList();
    for (var item in list) {
      // print(item['reserve']);
      if (item['reserve'] != null) {
        // print('${item['reserve']['day'].toString()} ${item['reserve']['time'].toString()}');
        List<String> day=item['reserve']['day'].toString().split(" ");
        List<String> time=item['reserve']['time'].toString().split(":");


        Appointment appointment = Appointment(
          subject: item['name'],
          startTime: DateTime(int.parse(day[0]), int.parse(day[1]), int.parse(day[2]), int.parse(time[0]), int.parse(time[1]), 0),
          endTime: DateTime(int.parse(day[0]), int.parse(day[1]), int.parse(day[2]), int.parse(time[0]), int.parse(time[1]), 0).add(const Duration(minutes:30)),
          color: Colors.black,
          notes: "",
          isAllDay: false,
        );
        if(mounted) {

          setState(() {
            _appointments.add(appointment);
          });

        }
      }

    }






    // 메모: 여기에서 원하는 일정을 만들 수 있습니다.
    // 예를 들면, 'eventName'과 'startTime', 'endTime' 등을 포함하는 Appointment 객체를 만들 수 있습니다.
    // Appointment appointment = Appointment(
    //   subject: subjectName,
    // startTime: DateTime(startDate.year, startDate.month, startDate.day),
    // endTime: DateTime(startDate.year, startDate.month, startDate.day,
    //     endAt[0], endAt[1], 0),
    // color: Colors.blue,
    // );

    // _appointments.add(appointment);
  }

  void getTempAppointments(
      String subjectName, String startTime, String endTime, String day) {
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
      recurrenceRule: 'FREQ=WEEKLY;BYDAY=$day;',
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
