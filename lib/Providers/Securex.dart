import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';

import '../ProviderInterface.dart';

class Securex implements ProviderInterface {
  String name = "Securex";
  String url = 'https://securex.pe/';
  String publicUrl = 'https://securex.pe/';

  Future<String> fetchData() async {
    String resultado = "10";
    String fullUrl = this.url;

    Response response = await get(
      fullUrl,
      headers: {
        //'Content-type': "application/x-www-form-urlencoded; charset=UTF-8"
      },
    );

    print(response.statusCode.toString());
    //print(response.body);

    var document = parse(response.body);
    resultado = document.getElementsByClassName("pVenta").last.text;

    return resultado;
  }
}
