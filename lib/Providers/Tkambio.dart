import 'dart:convert';

import 'package:http/http.dart';
import 'package:lukex/MainProvider.dart';

import '../ProviderInterface.dart';

class Tkambio extends MainProvider implements ProviderInterface {
  String name = "TKambio";
  String url = 'https://tkambio.com/wp-admin/admin-ajax.php';
  String publicUrl = 'https://tkambio.com';

  @override
  String getData() {
    String data = "0";

    //var rng = new Random();
    return data; //rng.nextInt(20).toString();
  }

  Future<String> fetchData() async {
    //var response = await http.get(this.url);
    Response response =
        await post(new Uri(path: url), body: {'action': 'get_tipo_cambio'});

    // sample info available in response
    //int statusCode = response.statusCode;

    Map<String, dynamic> parsed = jsonDecode(response.body);
    String data = parsed['buy_type_change'];

    return data;
  }
}
