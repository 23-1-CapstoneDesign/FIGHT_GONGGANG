import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryWidget extends StatefulWidget {
  GalleryWidget();

  @override
  _GalleryWidgetState createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  String? ID;
  String? title;
  static final dburl = dotenv.env["MONGO_URL"].toString();
  List<Map<String, dynamic>>? result = null;
  bool _dataloaded = false;

  @override
  void initState() {
    getData();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('policy');

    collection
        .find(mongo.where.sortBy('정책 ID', descending: true))
        .toList()
        .then((list) {
      if (mounted) {
        setState(() {
          result = list;
          _dataloaded = true;
        });
      }
    });
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void showPolicyPopup(Map<String, dynamic>? policy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(policy?['정책명']),
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("정책소개:${policy?['정책소개']}"),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            Text("지원내용:${policy?['지원내용']}"),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            if (policy?['지원규모'] != '-' || policy?['지원규모'] != 'null')
              Column(children: [
                Text("지원규모:${policy?['지원규모']}"),
                Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                )
              ]),
            if (policy?['학력'] != '제한없음')
              Column(children: [
                Text("학력 제한:${policy?['학력']}"),
                Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                )
              ]),
            if (policy?['전공'] != '제한없음')
              Column(children: [
                Text("전공 제한:${policy?['전공']}"),
                Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                )
              ]),
            Text("연령제한:${policy?['연령']}"),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            Text("신청기관:${policy?['신청기관명']}"),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            Text("신청기간:${policy?['신청기간']}"),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            Text("신청절차:${policy?['신청절차']}"),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            TextButton(
                onPressed: () {
                  // if (!policy?['사이트 링크 주소'].startsWith('http://') && !policy?['사이트 링크 주소'].startsWith('https://')) {
                  //   _launchUrl( Uri.parse('http:'+policy?['사이트 링크 주소']));
                  // }
                  // _launchUrl( Uri.parse(policy?['사이트 링크 주소']));
                  //
                },
                child: Text(
                  "사이트 링크:${policy?['사이트 링크 주소']}",
                  style: TextStyle(color: Colors.black),
                )),
          ]),
          actions: [
            Center(
              child: TextButton(
                child: Text('닫기'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal, // 수평 스크롤을 위해 설정
      itemCount: result?.length,
      itemBuilder: (BuildContext context, int index) {
        if (_dataloaded)
          return GestureDetector(
            onTap: () {
              // 카드를 클릭했을 때 실행되는 코드
              showPolicyPopup(result![index]);
            },
            child: Container(
              width: 200,
              // 카드의 너비를 조정하고 싶은 값으로 설정
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    result?[index]['정책명'],
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      result?[index]['신청기간'],
                      style: TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
      },
    );
  }
}
