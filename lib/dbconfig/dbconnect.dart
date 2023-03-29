import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<MySqlConnection> config() async {
  var settings;


  var host = dotenv.env["HOST"].toString();
  var user= dotenv.env["DB_USER"];
  var password= dotenv.env["DB_PASSWORD"];
  var db= dotenv.env["DB_NAME"];

  MySqlConnection conn = await MySqlConnection.connect(ConnectionSettings(
      host: host,
      port: 3306,
      user:  dotenv.env["DB_USER"],
      db: dotenv.env["DB_NAME"],
      password: dotenv.env["DB_PASSWORD"]));


  Future<Results> result = conn.query("SHOW DATABASE;");
  return conn;

}

