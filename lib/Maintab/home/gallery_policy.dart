import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:url_launcher/url_launcher.dart';

class GalleryWidget extends StatefulWidget {
  const GalleryWidget({super.key});

  @override
  GalleryWidgetState createState() => GalleryWidgetState();
}

class GalleryWidgetState extends State<GalleryWidget> {
  String? id;
  String? title;
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();
  List<Map<String, dynamic>>? result;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    mongo.Db conn = await mongo.Db.create(dbUrl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('policy');
    var list = await collection
        .find(mongo.where.sortBy('정책 ID', descending: true))
        .toList();
    if (mounted) {
      setState(() {
        result = list;
        _dataLoaded = true;
      });
    }

    conn.close();
  }

  Future<void> _launchUrl(Uri url) async {
    canLaunchUrl(url).then((value) async {
      if (value) {
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      }
    });
  }

  Future<void> _showConfirmationDialog(Uri url) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('링크 열기'),
          content: const Text('링크를 여시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl(url);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPolicyPopup(Map<String, dynamic>? policy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              policy?['정책명'],
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              "정책소개 ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("${policy?['정책소개']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const Text(
              "정책유형 ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${policy?['정책유형']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "지원내용 ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("${policy?['지원내용']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            if (policy?['지원규모'] != '-' || policy?['지원규모'] != 'null')
              Column(children: [
                const Text(
                  "지원규모 ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${policy?['지원규모']}"),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                )
              ]),
            if (policy?['학력'] != '제한없음')
              Column(children: [
                const Text(
                  "학력 제한 ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${policy?['학력']}"),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                )
              ]),
            if (policy?['전공'] != '제한없음')
              Column(children: [
                const Text(
                  "전공 제한 ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${policy?['전공']}"),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                )
              ]),
            const Text(
              "연령제한 ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("${policy?['연령']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const Text(
              "신청기관 ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("${policy?['신청기관명']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const Text(
              "신청기간 ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("${policy?['신청기간']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const Text(
              "신청절차 ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("${policy?['신청절차']}"),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 2,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            TextButton(
                onPressed: policy != null &&
                        policy['사이트 링크 주소'].toString().contains(".")
                    ? () {
                        if (!policy['사이트 링크 주소'].startsWith('http://') &&
                            !policy['사이트 링크 주소'].startsWith('https://')) {
                          Uri? uri =
                              Uri.tryParse("http://${policy['사이트 링크 주소']}");
                          if (uri != null && uri.isAbsolute) {
                            _showConfirmationDialog(uri);
                          }
                        } else {
                          _showConfirmationDialog(policy['사이트 링크 주소']);
                        }
                      }
                    : null,
                child: Text(
                  "사이트 링크:${policy?['사이트 링크 주소']}",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                )),
          ]),
          actions: [
            Center(
              child: TextButton(
                child: const Text('닫기'),
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
    if (_dataLoaded) {
      //todo
      return ListView.builder(
        scrollDirection: Axis.horizontal, // 수평 스크롤을 위해 설정
        itemCount: result?.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // 카드를 클릭했을 때 실행되는 코드
              showPolicyPopup(result![index]);
            },
            child: Container(
              width: 200,
              // 카드의 너비를 조정하고 싶은 값으로 설정
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
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
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      result?[index]['신청기간'],
                      style: const TextStyle(fontSize: 18),
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
    } else {
      return const Align(child: SizedBox(

        child: CircularProgressIndicator(),
      ),);
    }
  }
}
