import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Database {
  static final dburl = dotenv.env["MONGO_URL"].toString();

  Future<BulkWriteResult> insertmany(
      String collection_name, List<Map<String, dynamic>> value) async {
    Db conn = await Db.create(dburl);
    await conn.open();
    DbCollection collection = conn.collection(collection_name);

    var result = await collection.insertMany(value);
    conn.close();
    return result;
  }

  Future<Map<String, dynamic>> insert(
      String collectionName, Map<String, dynamic> value) async {
    Db conn = await Db.create(dburl);
    await conn.open();
    DbCollection collection = conn.collection(collectionName);

    var result = await collection.insert(value);
    conn.close();
    return result;
  }
}
