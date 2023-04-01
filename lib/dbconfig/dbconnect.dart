import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Database{

  static final _host = dotenv.env["HOST"].toString();
  static final _user= dotenv.env["DB_USER"];
  static final _password= dotenv.env["DB_PASSWORD"];
  static final _db= dotenv.env["DB_NAME"];
  static final _port=int.parse(dotenv.env["PORT"].toString());

  static final Database instance = Database._getInstance();



  static late MySqlConnection _connection;

  Database._getInstance();





  // Open a connection to the MySQL database

  Future<MySqlConnection> getConnection() async {
    if (_connection != null) return _connection;
    _connection = await MySqlConnection.connect(ConnectionSettings(
        host: _host,
        port: _port,
        user: _user,
        password: _password,
        db: _db));
    return _connection;
  }

  // 메모리 활용을 최소화 하기위해 실행중에만 커넥션을 유지
  Future<void> closeConnection() async {
    if (_connection == null) return;
    await _connection.close();
  }


  // 쿼리문 실행 함수
  Future<Results> executeQuery(String query, [List<dynamic>? params]) async {
    var conn = await getConnection();
    var results = conn.query(query, params);
    return results;
  }





}
// Future<MySqlConnection> config() async {
//
//   // MySqlConnection conn = await MySqlConnection.connect(ConnectionSettings(
//   //     host: host,
//   //     port: 3306,
//   //     user:  dotenv.env["DB_USER"],
//   //     db: dotenv.env["DB_NAME"],
//   //     password: dotenv.env["DB_PASSWORD"]));
//
//   var settings = new ConnectionSettings(
//       host: host,
//       port: port,
//       user: user,
//       password: password,
//       db: db
//   );

  // var conn = await MySqlConnection.connect(settings);
  //
  // Future<List<Map<String, dynamic>>> _getResults() async {
  //
  //   final results = await conn.query('SELECT * FROM users');
  //   await conn.close();
  //   return results.map((r) => r.fields).toList();
  // }






  // return conn;

// }

