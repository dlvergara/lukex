import 'package:flutter/material.dart';
import 'package:lukex/MainProvider.dart';
import 'package:url_launcher/url_launcher.dart';

class LukexTile extends ListTile {
  late MainProvider _provider;
  late ListTile _tile;

  ListTile get tile => _tile;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  LukexTile(MainProvider provider, Widget logo, String data, Icon icon) {
    this._tile = ListTile(
      enabled: true,
      leading: logo,
      title: Text(provider.name),
      subtitle: Text(data),
      trailing: icon,
      isThreeLine: true,
      onTap: () {
        _launchURL(provider.publicUrl);
      },
    );
  }

  MainProvider get provider => _provider;

  set provider(MainProvider value) {
    _provider = value;
  }
}
