import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kafka/kafka.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Util/StorageMessage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ProviderInterface.dart';
import '../pages/MyHomePage.dart';

class MyHomePageState extends State<MyHomePage> {
  double minusConstant = 0.004;
  double minValue = 10.0;

  CocosYLucas cocosyLucasProvider = new CocosYLucas();
  Tkambio tkambioProvider = new Tkambio();
  JetPeru jetPeruProvider = new JetPeru();
  CambistaInca cambistaProvider = new CambistaInca();

  Future<void> _sendToStorage(String provider, String data) async {
    final now = new DateTime.now();
    String formatter = DateFormat('y-M-d_H:m:s').format(now);

    var config = new ProducerConfig(bootstrapServers: ['107.170.208.14:9092']);
    var producer = new Producer<String, String>(
        new StringSerializer(), new StringSerializer(), config);

    StorageMessage msg = new StorageMessage(data, formatter);
    String message = jsonEncode(msg);

    var record = new ProducerRecord("lukex_" + provider, 0, formatter, message);
    producer.add(record);
    await record.result; //var result =
    await producer.close();
  }

  void _incrementCounter() {
    setState(() {});
  }

  bool findMinValue(double value) {
    print(this.minValue);
    bool res = false;
    if (value < this.minValue) {
      this.minValue = value;
      res = true;
    }
    return res;
  }

  List<Widget> getChildren(
      AsyncSnapshot<String> snapshot, ProviderInterface provider) {
    List<Widget> children;
    double exchangeValue = 0.0;
    _sendToStorage(provider.name, snapshot.data);
    Color fontColor = Colors.grey;
    try {
      exchangeValue = double.parse(snapshot.data);
      bool founded = findMinValue(exchangeValue);
      if (founded) {
        fontColor = Colors.green;
      }
      double minus = exchangeValue - minusConstant;
      children = <Widget>[
        ListTile(
          enabled: true,
          leading: FlutterLogo(size: 72.0),
          title: Text(provider.name),
          subtitle: Text(
            '${snapshot.data} / ${minus}',
            style: TextStyle(
              color: fontColor,
            ),
          ),
          trailing: Icon(Icons.more_vert),
          isThreeLine: true,
          onTap: () {
            _launchURL(provider.publicUrl);
          },
        )
      ];
    } on Exception {
      //print('Format error!');
      children = <Widget>[
        ListTile(
          enabled: true,
          leading: FlutterLogo(size: 72.0),
          title: Text(provider.name),
          subtitle: Text('${snapshot.data}'),
          trailing: Icon(Icons.more_vert),
          isThreeLine: true,
          onTap: () {
            _launchURL(provider.publicUrl);
          },
        )
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Widget> buildChildren(
      AsyncSnapshot<String> snapshot, ProviderInterface provider) {
    List<Widget> children;
    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
      //print(provider.name + " - data arrived!");
      children = getChildren(snapshot, provider);
    } else if (snapshot.hasError) {
      //print(provider.name + " - error: "+ snapshot.error);
      children = getErrorChildren(snapshot);
    } else {
      //print(provider.name + " - loading...");
      children = getLoadingChildren();
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    this.minValue = 10;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Card(
              child: FutureBuilder<String>(
                future: this.cocosyLucasProvider.fetchData(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children =
                      buildChildren(snapshot, this.cocosyLucasProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ),
            ),
            Card(
              child: FutureBuilder<String>(
                future: this.tkambioProvider.fetchData(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children =
                      buildChildren(snapshot, this.tkambioProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ),
            ),
            Card(
              child: FutureBuilder<String>(
                future: this.jetPeruProvider.fetchData(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children =
                      buildChildren(snapshot, this.jetPeruProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ),
            ),
            Card(
              child: FutureBuilder<String>(
                future: this.cambistaProvider.fetchData(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children =
                      buildChildren(snapshot, this.cambistaProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
