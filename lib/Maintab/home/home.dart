import 'package:fighting_gonggang/Maintab/Maintab.dart';
import 'package:fighting_gonggang/Maintab/home/gallery_policy.dart';
import 'package:fighting_gonggang/Maintab/timetable/add_class.dart';
import 'package:flutter/material.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:fighting_gonggang/Maintab/timetable/Timetable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fighting_gonggang/Maintab/home/my_party.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

// class HomePage extends StatelessWidget {
class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 이전 페이지로 이동하지 않고 원하는 동작을 수행
        // 예를 들면 다이얼로그 표시 등
        return false; // true를 반환하면 이전 페이지로 이동
      },
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const TimeTable(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddClass()),
                    ).then((value) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainTabPage()));
                    });
                  },
                  child: const Text('시간표 등록하러 가기'),
                ),

                //
              ]),
              const Divider(
                height: 2,
                color: Colors.green,
              ),
              Align(
                child: Text(
                  "참여중인 파티",
                  style: GoogleFonts.gamjaFlower(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 200,
                child: Expanded(
                  child: MyParty(),
                ),
              ),
              const Divider(
                height: 2,
                color: Colors.green,
              ),
              Column(
                children: [
                  Align(
                    child: Text(
                      "청년 정책",
                      style: GoogleFonts.gamjaFlower(fontSize: 25),
                      // style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                      height: 200,
                      child: Row(children: [Expanded(child: GalleryWidget())]))
                ],
              ),
            ],
          ),
        ),
        drawer: const Drawer(
          child: Dashboard(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
