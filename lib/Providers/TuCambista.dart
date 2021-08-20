import 'dart:convert';

import 'package:http/http.dart';
import 'package:lukex/MainProvider.dart';

import '../ProviderInterface.dart';

class TuCambista extends MainProvider implements ProviderInterface {
  String name = "TuCambista";
  String url = 'https://app.tucambista.pe/';
  String publicUrl = 'https://www.tucambista.pe/';

  Future<String> fetchData() async {
    String resultado = "20.1";
    var time = new DateTime.now().millisecondsSinceEpoch;
    String fullUrl =
        this.url + 'api/transaction/getquote/500/USD/BUY/?_=' + time.toString();

    Response response = await get(
        new Uri(path: fullUrl),
      headers: {
        //'Content-type': "application/x-www-form-urlencoded; charset=UTF-8"
      },
    );

    //print(response.statusCode.toString());
    //print(response.body);

    Map<String, dynamic> parsed = jsonDecode(response.body);
    if (parsed['id'] != "") {
      resultado = parsed['exchangeRateUsed'].toString();
    } else {
      resultado = response.body;
    }

    return resultado;
  }
}
