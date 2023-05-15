// 임시 추후 삭제 코드
import 'package:flutter/material.dart';
import 'community_youthPolicy_DB.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> policyData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var communityYouthPolicy = CommunityYouthPolicy();
    var data = await communityYouthPolicy.connectToMongoDB();
    setState(() {
      policyData = communityYouthPolicy.policyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('청년 정책'),
        ),
        body: ListView.builder(
          itemCount: policyData.length,
          itemBuilder: (context, index) {
            var policy = policyData[index];
            return ListTile(
              title: Text(policy['정책명']),
              subtitle: Text(policy['정책소개']),
              // 여기에 필요한 데이터 필드 추가
            );
          },
        ),
      ),
    );
  }
}
