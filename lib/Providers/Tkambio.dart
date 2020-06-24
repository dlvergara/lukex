import 'dart:convert';

import 'package:http/http.dart';

import '../ProviderInterface.dart';

class Tkambio implements ProviderInterface {
  String url = 'https://tkambio.com/wp-admin/admin-ajax.php';

  @override
  String getData() {
    String data = "0";

    //var rng = new Random();
    return data; //rng.nextInt(20).toString();
  }

  Future<String> fetchData() async {
    //var response = await http.get(this.url);
    Response response = await post(url, body: {'action': 'get_tipo_cambio'});

    // sample info available in response
    int statusCode = response.statusCode;

    Map<String, dynamic> parsed = jsonDecode(response.body);
    String data = parsed['buy_type_change'];

    return data;
  }
}
