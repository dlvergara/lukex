import 'package:flutter/material.dart';
import 'package:lukex/MainProvider.dart';
import 'package:lukex/Util/ProviderGenerator.dart';
import 'package:lukex/Util/Util.dart';

import 'LukexTile.dart';

class LukexCard extends Card {
  MainProvider _provider;
  double _amount;
  Card _card;
  ProviderGenerator gen = new ProviderGenerator();
  Util util = new Util();

  Card get card => _card;

  double get amount => _amount;

  MainProvider get provider => _provider;

  LukexCard(dynamic provider) {
    this._provider = provider;
    this._amount = 10;
    this._card = Card(
      child: FutureBuilder<String>(
        future: provider.fetchData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          List<Widget> children = buildChildren(snapshot, provider);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildChildren(
      AsyncSnapshot<String> snapshot, MainProvider provider) {
    List<Widget> children;
    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
      children = getChildren(snapshot, provider);
    } else if (snapshot.hasError) {
      children = getErrorChildren(snapshot);
      this._amount = 0;
    } else {
      this._amount = 10;
      children = getLoadingChildren();
    }
    return children;
  }

  List<Widget> getChildren(
      AsyncSnapshot<String> snapshot, MainProvider provider) {
    List<Widget> children;
    double exchangeValue = 0.0;
    Widget logo = gen.getLogo(provider);

    try {
      exchangeValue = double.parse(snapshot.data);
      if (exchangeValue >= 0) {
        util.sendToStorage(provider.name, snapshot.data);
        this._amount = exchangeValue;
      } else {
        util.sendToStorage(provider.name, "10");
        this._amount = 10;
      }

      children = <Widget>[
        new LukexTile(provider, logo, '${snapshot.data}', Icon(Icons.more_vert))
            .tile
      ];
    } on Exception {
      children = <Widget>[
        new LukexTile(provider, logo, '${snapshot.data}', Icon(Icons.more_vert))
            .tile
      ];
    }

    return children;
  }

  List<Widget> getErrorChildren(snapshot) {
    double iconSize = 60;
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: Colors.red,
        size: iconSize,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Text('Error: ${snapshot.error}'),
      )
    ];
  }

  List<Widget> getLoadingChildren() {
    return <Widget>[
      SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
      const Padding(
        padding: EdgeInsets.only(top: 1),
        child: Text('Cargando...'),
      )
    ];
  }
}
