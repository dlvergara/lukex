import 'dart:convert';

import 'package:http/http.dart';
import 'package:lukex/MainProvider.dart';

import '../ProviderInterface.dart';

class CambistaInca extends MainProvider implements ProviderInterface {
  String name = "CambistaInca";
  String url = 'https://cambistainka.com';
  String publicUrl = 'https://cambistainka.com';

  Future<String> fetchData() async {
    String resultado = "20.1";
    String fullUrl = this.url + '/admin/obtenertipocambio.php';

    Response response = await post(Uri.parse(fullUrl), headers: {
      'Content-type': "application/x-www-form-urlencoded; charset=UTF-8",
      'Access-Control-Allow-Origin': '*',
      'Accept': 'application/json',
      'Origin': this.url
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
