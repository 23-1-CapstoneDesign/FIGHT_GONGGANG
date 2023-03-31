import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<MySqlConnection> config() async {


  var host = dotenv.env["HOST"].toString();
  var user= dotenv.env["DB_USER"];
  var password= dotenv.env["DB_PASSWORD"];
  var db= dotenv.env["DB_NAME"];

  // MySqlConnection conn = await MySqlConnection.connect(ConnectionSettings(
  //     host: host,
  //     port: 3306,
  //     user:  dotenv.env["DB_USER"],
  //     db: dotenv.env["DB_NAME"],
  //     password: dotenv.env["DB_PASSWORD"]));

  var settings = new ConnectionSettings(
      host: dotenv.env["HOST"].toString(),
      port: 3306,
      user: dotenv.env["DB_USER"],
      password: dotenv.env["DB_PASSWORD"],
      db: dotenv.env["DB_NAME"]
  );

  var conn = await MySqlConnection.connect(settings);



  return conn;

}

