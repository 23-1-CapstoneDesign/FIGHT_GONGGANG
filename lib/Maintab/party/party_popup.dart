import 'package:flutter/material.dart';

class PartyDetailsPopup extends StatelessWidget {
  final String partyName;
  final String tag;
  final int currentMembers;
  final int totalMembers;
  final String? description;

  PartyDetailsPopup({
    required this.partyName,
    required this.tag,
    required this.currentMembers,
    required this.totalMembers,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(partyName),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('태그: $tag'),
          Text('현재 인원: $currentMembers/$totalMembers'),
          Text('소개: $description'),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 입장 버튼을 누른 후의 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              child: Text('입장'),
            ),
          ],
        ),
      ],
    );
  }
}
