import 'dart:convert';

import 'package:http/http.dart';

import '../ProviderInterface.dart';

class CambistaInca implements ProviderInterface {
  String url = 'https://cambistainka.com';

  Future<String> fetchData() async {
    String resultado = "20.1";
    String fullUrl = this.url + '/admin/obtenertipocambio.php';
    print(fullUrl);

    Response response = await post(fullUrl, headers: {
      'Content-type': "application/x-www-form-urlencoded; charset=UTF-8"
    }, body: {
      'cTipoOperacion': "01",
      'nMontoDolares': "0",
      'bEsInicial': "1",
      'bEsTCPref': "0"
    });

    //print(response.statusCode.toString());
    //print(response.body);

    Map<String, dynamic> parsed = jsonDecode(response.body);
    if (parsed['success']) {
      resultado = parsed['data']['tipocambio']['0']['nTCVenta'];
    } else {
      resultado = response.body;
    }

    return resultado;
  }
}
