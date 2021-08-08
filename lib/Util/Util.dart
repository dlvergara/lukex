import 'Database.dart';

class Util {
  ///Send to database
  Future<void> sendToStorage(String provider, String data) async {
    var db = new Database();
    var conn = await db.getConnection();
    var insertQuery =
        "INSERT INTO lukex.exchange VALUES (null, NOW(), ?, ?, '--')";
    await conn.query(insertQuery, ["lukex_" + provider, data]);
  }
}
