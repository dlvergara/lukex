import 'dart:convert';

//import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';
import 'package:lukex/MainProvider.dart';

import '../ProviderInterface.dart';

class Cambista extends MainProvider implements ProviderInterface {
  String name = "Cambista";
  String url = 'https://cambista.com/api-rest/js/calc.json';
  String publicUrl = 'https://cambista.com/';

  Future<String> fetchData() async {
    String resultado = "10";
    String fullUrl = this.url;

    Response response = await get(
      Uri.parse(fullUrl),
      headers: {
        //'Content-type': "application/x-www-form-urlencoded; charset=UTF-8"
      },
    );

    //print(response.statusCode.toString());
    //print(response.body);

    Map<String, dynamic> parsed = jsonDecode(response.body);
    if (parsed['site']['dollar']['price_v'] != "") {
      resultado = parsed['site']['dollar']['price_v'].toString();
    } else {
      resultado = response.body;
    }

    return resultado;
  }
}
