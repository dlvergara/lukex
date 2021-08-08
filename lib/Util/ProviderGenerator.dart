import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lukex/Providers/Acomo.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/MidPointFx.dart';
import 'package:lukex/Providers/Securex.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/Database.dart';
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
        print('Provider from db -> ' + name);
        MainProvider provider = null;
        switch (name) {
          case 'TuCambista':
            provider = new TuCambista();
            break;
          case 'JetPeru':
            provider = new JetPeru();
            break;
          case 'CambistaInca':
            provider = new CambistaInca();
            break;
          case 'Acomo':
            provider = new Acomo();
            break;
          case 'Tkambio':
            provider = new Tkambio();
            break;
          case 'CocosYLucas':
            provider = new CocosYLucas();
            break;
          case 'MidPointFx':
            provider = new MidPointFx();
            break;
          case 'Securex':
            provider = new Securex();
            break;
        }
        provider.logo = row['logo'];
        provider.name = row['name'];

        providerList.add(provider);
      }
    } catch (e) {
      print('Printing out the message: $e');
    }

    return providerList;
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
