import 'package:http/http.dart';

import '../ProviderInterface.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class CocosYLucas implements ProviderInterface {
  String url = 'https://www.cocosylucasbcp.com/poly/external-exchange-rate';

  String getData() {
    //String data;
    //this._fetchData().then((value) => data = value);

    var rng = new Random();

    return rng.nextInt(10).toString();
  }

  Future<String> fetchData() async {
    //var response = await http.get(this.url);
    Response response = await post(url);

    // sample info available in response
    int statusCode = response.statusCode;
    //print(statusCode);
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    //print(contentType);

    String htmlData = response.body;
    //print(htmlData);

    var document = parse(htmlData);
    //print(document.getElementById("textERSale"));
    //print(document.querySelector("#textERSale"));
    //print(document.body.querySelector("#textERSale"));

    return response.statusCode.toString();
  }
}
