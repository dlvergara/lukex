import 'dart:convert';

import 'package:http/http.dart';
import 'package:lukex/MainProvider.dart';

import '../ProviderInterface.dart';

class Roblex extends MainProvider implements ProviderInterface {
  String name = "Roblex";
  String url = 'https://operations.roblex.pe/valuation/active-valuation';
  String publicUrl = 'https://roblex.pe/';

  Future<String> fetchData() async {
    String resultado = "10";
    String fullUrl = this.url;

    Response response = await get(
      fullUrl,
      headers: {
        //'Content-type': "application/x-www-form-urlencoded; charset=UTF-8"
      },
    );

    //print(response.statusCode.toString());
    //print(response.body);

    Map<String, dynamic> parsed = jsonDecode(response.body);
    resultado = parsed['amountSale'];
    return resultado;
  }
}
