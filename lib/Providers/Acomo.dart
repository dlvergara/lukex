import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import '../MainProvider.dart';
import '../ProviderInterface.dart';

class Acomo extends MainProvider implements ProviderInterface {
  String name = "AComo";
  String publicUrl = 'https://www.acomo.com.pe/';
  String url = 'https://www.acomo.com.pe/api/current_change';

  String getData() {
    var rng = new Random();

    return rng.nextInt(10).toString();
  }

  Future<String> fetchData() async {
    String result = "0.0";

    Response response = await get(url, headers: {
      //'referer': 'https://www.cocosylucasbcp.com/',
      //'app-code': 'MY',
    });
    //print("A como status: " + response.statusCode.toString());
    //print("A como response: " + response.body);

    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);

      if (parsed.containsKey('OFFER')) {
        result = parsed['OFFER'].toString();
      } else {
        result = response.body;
      }
    } else {
      result = response.body;
    }

    return result;
  }
}
