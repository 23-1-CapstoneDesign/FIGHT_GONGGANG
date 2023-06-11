import 'package:flutter/material.dart';

class TimeDetailsPopup extends StatelessWidget {
  final String name;
  final List<dynamic>? appointments;

  const TimeDetailsPopup(
      {super.key, required this.name, required this.appointments});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime;

    return AlertDialog(
      title: Text("강의/파티명 :${appointments?[0].subject}"),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("교수/파티 명:$name"),
        Text("시작시간:${appointments?[0].startTime.hour}:${appointments?[0].startTime.minute.toString().padLeft(2, "0")}"),
        Text("종료시간:${appointments?[0].endTime.hour}:${appointments?[0].endTime.minute.toString().padLeft(2, "0")}"),
      ]),

      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);

                // 입장 버튼을 누른 후의 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('수업 삭제'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);

                // 입장 버튼을 누른 후의 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      ],
    );
  }
}
