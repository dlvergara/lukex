import 'package:localstorage/localstorage.dart';

import 'Database.dart';

class Util {
  final LocalStorage storage = new LocalStorage('lukex.json');

  ///Send to database
  Future<void> sendToStorage(String provider, String data) async {
    var db = new Database();
    var conn = await db.getConnection();
    var insertQuery =
        "INSERT INTO lukex.exchange VALUES (null, NOW(), ?, ?, '--')";
    await conn.query(insertQuery, ["lukex_" + provider, data]);
  }

  saveToLocalStorage(value) {
    storage.setItem('lukex_min_val_usd', value);
  }

  clearLocalStorage() async {
    try {
      await storage.clear();
    } catch (e) {
      print("------------- Exception -------------");
      print(e);
      print("------------- /Exception -------------");
    }
  }

  getFromLocalStorage() {
    double variable = 0;
    try {
      variable = storage.getItem('lukex_min_val_usd');
    } catch (e) {
      print("------------- Exception -------------");
      print(e);
      print("------------- /Exception -------------");
    }
    return variable;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s) != null;
  }
}
