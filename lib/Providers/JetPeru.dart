import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import '../MainProvider.dart';
import '../ProviderInterface.dart';

class JetPeru extends MainProvider implements ProviderInterface {
  String name = "JetPeru";
  String url = 'http://www.jetperu.com.pe/';
  String publicUrl = 'http://www.jetperu.com.pe';

  String getData() {
    //var data = this._fetchData();
    var rng = new Random();

    return rng.nextInt(5).toString();
  }

  Future<String> getToken() async {
    //var response = await http.get(this.url);
    Response response = await post('http://jetperu.com.pe/_procesos.php',
        body: {'fn': 'obtenerToken'});

    //final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    Map<String, dynamic> parsed = jsonDecode(response.body);
    String data = parsed['dato'];

    return data;
  }

  Future<String> fetchData() async {
    String resultado = "";
    String token = await getToken();

    Map<String, String> headers = {"Authorization": "Bearer $token"};
    Response response = await get(
        'http://apitc.jetperu.com.pe:5002/api/WebTipoCambio?monedaOrigenId=PEN',
        headers: headers);

    //print(response.statusCode);
    //print(response.body);
    Map<String, dynamic> parsed = jsonDecode(response.body);
    List data = parsed['dato'];
    for (final i in data) {
      //print('$i');
      if (i['monedaDestinoId'] == 'USD') {
        resultado = i['tipoVenta'].toStringAsFixed(3);
      }
    }
    return resultado;
  }
}
