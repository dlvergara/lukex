import 'dart:convert';

import 'package:flutter/material.dart';
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
    //var response = await http.get(this.url);
    String token = await getToken();

    Response response = await get(url, headers: {
      'authorization': 'Bearer $token',
      'dnt': '1',
      'referer': 'https://www.cocosylucasbcp.com/',
      'app-code': 'MY',
    });
    //print(response.body);

    var parsed = json.decode(response.body);
    if (parsed.length > 0) {
      for (final i in parsed) {
        if (i['kind'] == "PARALLEL_MAIN") {
          print(i);
          result = i['sellRate'].toStringAsFixed(4);
          break;
        }
      }
    }

    return result;
  }
}
