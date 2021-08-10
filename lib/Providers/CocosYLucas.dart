import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:lukex/MainProvider.dart';

import '../ProviderInterface.dart';

class CocosYLucas extends MainProvider implements ProviderInterface {
  String name = "CocosyLucas";
  String publicUrl = 'https://www.cocosylucasbcp.com/';
  String url = 'https://www.cocosylucasbcp.com/poly/currency-exchanges';

  String getData() {
    //String data;
    //this._fetchData().then((value) => data = value);

    var rng = new Random();

    return rng.nextInt(10).toString();
  }

  Future<String> getToken() async {
    Response response =
        await post('https://www.cocosylucasbcp.com/toc', headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      'app-code': 'MY',
      'referer': 'https://www.cocosylucasbcp.com/',
      'origin': 'https://www.cocosylucasbcp.com',
      'dnt': '1',
    }, body: {
      'fn': 'obtenerToken'
    });

    Map<String, dynamic> parsed = jsonDecode(response.body);
    String data = parsed['access_token'];

    return data;
  }

  Future<String> fetchData() async {
    String result = "0.0";
    String token = await getToken();

    Response response = await get(url, headers: {
      'authorization': 'Bearer $token',
      'dnt': '1',
      'referer': 'https://www.cocosylucasbcp.com/',
      'app-code': 'MY',
    });
    //print("cocos status: " + response.statusCode.toString());
    //print("cocos response: " + response.body);

    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);
      if (parsed.containsKey('currencyExchangeList')) {
        if (parsed['currencyExchangeList'].length > 0) {
          //print(parsed['currencyExchangeList']);
          var exchanges = parsed['currencyExchangeList'];
          for (final i in exchanges) {
            if (i['maxUsdPurchase'] == "999.9900") {
              result = i['rateSale'];
              break;
            }
          }
        }
      } else {
        result = response.body;
      }
    } else {
      result = response.body;
    }

    return result;
  }
}
