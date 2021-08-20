import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lukex/Providers/Acomo.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/MidPointFx.dart';
import 'package:lukex/Providers/Roblex.dart';
import 'package:lukex/Providers/Securex.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/Database.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart' as p;

import '../MainProvider.dart';

class ProviderGenerator {
  Future<List> GetProviders() async {
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
      for (var row in results) {
        String name = row['class_name'];
        //print('Provider from db -> ' + name);
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
        }
      }
    } catch (e) {
      print('Printing out the message: $e');
    }

    return providerList;
  }

  setProviderData(MainProvider provider, ResultRow row) {
    provider.id = row['id'];
    provider.logo = row['logo'];
    provider.name = row['name'];
  }

  Widget getLogo(MainProvider provider) {
    Widget logo = FlutterLogo(size: 72.0);
    if (provider.logo != null && provider.logo != '') {
      logo = Image.network(provider.logo);
      String extension = p.extension(provider.logo);
      if (extension == '.svg') {
        logo = SvgPicture.network(provider.logo);
      }
    }
    return logo;
  }
}
