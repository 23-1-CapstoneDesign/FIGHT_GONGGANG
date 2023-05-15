import 'package:flutter/material.dart';
import 'community_youthPolicy_DB.dart';

class YouthPolicyPage extends StatefulWidget {
  @override
  _YouthPolicyPageState createState() => _YouthPolicyPageState();
}

class _YouthPolicyPageState extends State<YouthPolicyPage> {
  List<Map<String, dynamic>> policyData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var communityYouthPolicy = CommunityYouthPolicy();
    await communityYouthPolicy.connectToMongoDB();
    setState(() {
      policyData = communityYouthPolicy.policyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('청년 정책'),
      ),
      body: ListView.builder(
        itemCount: policyData.length,
        itemBuilder: (context, index) {
          var policy = policyData[index];
          return ListTile(
            title: Text(policy['정책명']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('정책 유형: ${policy['정책유형']}'),
                Text('정책 소개: ${policy['정책소개']}'),
                Text('지원 내용: ${policy['지원내용']}'),
                Text('신청 기간: ${policy['신청기간']}'),
                Text('사이트 링크 주소: ${policy['사이트 링크 주소']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
