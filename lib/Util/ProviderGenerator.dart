import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lukex/Providers/Acomo.dart';
import 'package:lukex/Providers/Cambista.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/MidPointFx.dart';
import 'package:lukex/Providers/Roblex.dart';
import 'package:lukex/Providers/Securex.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/Database.dart';
import 'package:path/path.dart' as p;

import '../MainProvider.dart';

class ProviderGenerator {
  Future<List> GetProviders() async {
    var providerList = [];

    if (!kIsWeb) {
      providerList = await getProviderDataFromDb();
    } else {
      providerList = await getProviderDataFromFile();
    }
    return providerList;
  }

  Future<List> getProviderDataFromFile() async {
    var providerList = [];
    try {
      Map<String, dynamic> parsed = jsonDecode(
          '{"RECORDS":[{"id":"1","name":"JetPeru","class_name":"JetPeru","status":"1","sort":"1","logo":"http://www.jetperu.com.pe/images/favicon/favicon.ico"},{"id":"2","name":"TuCambista","class_name":"TuCambista","status":"1","sort":"2","logo":"https://www.tucambista.pe/favicon.svg"},{"id":"3","name":"CambistaInka","class_name":"CambistaInca","status":"1","sort":"1.1","logo":"https://cambistainka.com/images/favicon.ico"},{"id":"4","name":"Acomo","class_name":"Acomo","status":"1","sort":"1.01","logo":"https://www.acomo.com.pe/img/acomo-logo-icon.png"},{"id":"5","name":"CocosYLucas","class_name":"CocosYLucas","status":"1","sort":"2.1","logo":"https://www.cocosylucasbcp.com/assets/favicon/favicon-96x96.png"},{"id":"6","name":"Tkambio","class_name":"Tkambio","status":"0","sort":"2.2","logo":""},{"id":"7","name":"MidPointFx","class_name":"MidPointFx","status":"1","sort":"2.21","logo":"https://static.wixstatic.com/media/fe8e72_f3209a3b7b904e3b880c7c3182cc5cd4~mv2.png/v1/fill/w_32%2Ch_32%2Clg_1%2Cusm_0.66_1.00_0.01/fe8e72_f3209a3b7b904e3b880c7c3182cc5cd4~mv2.png"},{"id":"8","name":"Securex","class_name":"Securex","status":"1","sort":"2.2","logo":"https://securexweb.s3.amazonaws.com/ambientePrueba/Resources/WebContent/public/web/img/favicon.ico"},{"id":"9","name":"Roblex","class_name":"Roblex","status":"1","sort":"3","logo":"https://cdn.roblex.pe/favicon/favicon-32x32.png"},{"id":"10","name":"Cambista","class_name":"Cambista","status":"1","sort":"4","logo":"https://cambista.com/wp-content/uploads/2020/04/cropped-cambista-favi-icon-32x32.png"}]}');

      var results = parsed['RECORDS'];
      providerList = createProviderFromResult(results);
    } catch (e, stacktrace) {
      print('Printing out the message: $e');
      print(stacktrace);
    }

    return providerList;
  }

  //Get data from Database
  Future<List> getProviderDataFromDb() async {
    var providerList = [];

    try {
      var db = new Database();
      var conn = await db.getConnection();
      var results = await conn.query(
          'SELECT * FROM lukex.providers pro '
          'WHERE pro.status = 1 '
          'ORDER BY pro.sort',
          []);
      print("Providers found -> " + results.length.toString());
      providerList = createProviderFromResult(results);
    } catch (e) {
      print('Printing out the message: $e');
    }

    return providerList;
  }

  //Build each provider from list
  List createProviderFromResult(dynamic results) {
    var providerList = [];
    for (var row in results) {
      String name = row['class_name'];
      if (row['status'] == "1") {
        MainProvider provider;
        switch (name) {
          case 'TuCambista':
            provider = new TuCambista();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'JetPeru':
            provider = new JetPeru();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'CambistaInca':
            provider = new CambistaInca();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'Acomo':
            provider = new Acomo();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'Tkambio':
            provider = new Tkambio();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'CocosYLucas':
            provider = new CocosYLucas();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'MidPointFx':
            provider = new MidPointFx();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'Securex':
            provider = new Securex();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'Roblex':
            provider = new Roblex();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
          case 'Cambista':
            provider = new Cambista();
            setProviderData(provider, row);
            providerList.add(provider);
            break;
        }
      }
    }
    return providerList;
  }

  setProviderData(MainProvider provider, dynamic row) {
    if (row["id"] is String) {
      row["id"] = int.parse(row["id"]);
    }
    provider.id = row['id'];
    provider.logo = row['logo'];
    provider.name = row['name'];
  }

  Widget getLogo(MainProvider provider) {
    Widget logo = FlutterLogo(size: 72.0);
    if (provider.logo != '') {
      logo = Image.network(provider.logo);
      String extension = p.extension(provider.logo);
      if (extension == '.svg') {
        logo = SvgPicture.network(provider.logo);
      }
    }
    return logo;
  }
}
