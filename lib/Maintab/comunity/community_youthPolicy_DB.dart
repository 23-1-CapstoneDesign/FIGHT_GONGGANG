import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunityYouthPolicy {
  List<Map<String, dynamic>> policyData = [];

  Future<void> connectToMongoDB() async {
    final dburl = dotenv.env["MONGO_URL"].toString();
    // DB insert 부분
    mongo.Db db = await mongo.Db.create(dburl);

    await db.open();
    // 컬렉션 접근
    var collection = db.collection('aaaa');
    //쿼리 가져오기
    var policies = await collection.find().toList();

    policyData =
        policies.map((policy) => policy as Map<String, dynamic>).toList();

    await db.close();
  }
}

void main() {
  var communityYouthPolicy = CommunityYouthPolicy();
  communityYouthPolicy.connectToMongoDB();
}
