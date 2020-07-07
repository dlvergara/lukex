import 'package:mysql1/mysql1.dart';

class Database {
  var settings = new ConnectionSettings(
      host: '107.170.208.14',
      port: 3306,
      user: 'lukex',
      password: 'Lukex2010.',
      db: 'lukex');

  Future<MySqlConnection> getConnection() async {
    var conn = await MySqlConnection.connect(this.settings);
    return conn;
  }
}
