import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';

import '../ProviderInterface.dart';

class MidPointFx implements ProviderInterface {
  String name = "MidPointFx";
  String url = 'https://www.midpointfx.com/';
  String publicUrl = 'https://www.midpointfx.com/';

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
    //print(document.getElementById("comp-kdc9o3af").outerHtml);
    resultado = document
        .getElementById("comp-kdc9o3af")
        .getElementsByTagName("span")
        .last
        .text;

    return resultado;
  }
}
