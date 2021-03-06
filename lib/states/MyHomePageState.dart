import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kafka/kafka.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/StorageMessage.dart';
import 'package:lukex/pages/GraphPage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ProviderInterface.dart';
import '../pages/MyHomePage.dart';

class MyHomePageState extends State<MyHomePage> {
  double minusConstant = 0.004;
  double minValue = 10.0;
  var cards = [];
  var dataCollection = [];
  var queryDate = "";

  CocosYLucas cocosyLucasProvider = new CocosYLucas();
  Tkambio tkambioProvider = new Tkambio();
  JetPeru jetPeruProvider = new JetPeru();
  CambistaInca cambistaProvider = new CambistaInca();
  TuCambista tuCambistaProvider = new TuCambista();

  GraphPage graphPage = new GraphPage(
    title: 'Lukex - Gráfica',
    animate: true,
  );

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

  //Refresh
  void _incrementCounter() {
    this.getValues();
    setState(() {});
  }

  bool findMinValue(double value) {
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
      this.dataCollection.add([provider.name, exchangeValue]);

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
            '${snapshot.data}', // / ${minus}
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
      children = getChildren(snapshot, provider);
    } else if (snapshot.hasError) {
      children = getErrorChildren(snapshot);
    } else {
      children = getLoadingChildren();
    }
    return children;
  }

  // Get values
  void getValues() {
    this.cards = [];
    this.dataCollection = [];
    this.queryDate = new DateTime.now().toString();

    var providerCollection = [
      this.tuCambistaProvider,
      this.jetPeruProvider,
      this.tkambioProvider,
      this.cocosyLucasProvider,
      this.cambistaProvider,
    ];

    providerCollection.forEach((provider) {
      Widget card = Card(
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

      this.cards.add([provider.name, card]);
    });
  }

  @override
  void initState() {
    super.initState();
    this.getValues();
  }

  @override
  Widget build(BuildContext context) {
    this.minValue = 10;
    var finalCards = <Widget>[];

    this.cards.forEach((element) {
      finalCards.add(element[1]);
    });

    print(this.dataCollection);
    if (this.dataCollection.length > 0) {
      print("Ordenar!");
      finalCards = <Widget>[];

      print("cantidad 1: " + this.dataCollection.length.toString());
      this.dataCollection.sort((a, b) => a[1].compareTo(b[1]));

      this.dataCollection.forEach((dataElement) {
        for (final cardElement in this.cards) {
          if (dataElement[0] == cardElement[0]) {
            finalCards.add(cardElement[1]);
            break;
          }
        }
      });

      print("cantidad 2: " + this.dataCollection.length.toString());

      print(finalCards.length);
      print('fin ordernar');
      this.dataCollection = [];
    }
    print(this.dataCollection);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.title),
        /*
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            /*
            onPressed: () {
              print('Saltar a config');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => btConfig),
              );
            },
            */
          ),
        ]*/
      ),
      body: Column(children: <Widget>[
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //ORDERNAR
            new RaisedButton(
              child: new Text('Ordenar'),
              onPressed: () {
                setState(() {});
              },
            ),
            // GRAFICAS
            new RaisedButton(
              child: new Text('Gráfica'),
              onPressed: () {
                print('Saltar a graficas');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => this.graphPage),
                );
              },
            ),
          ],
        ),
        Text("Consulta: " + this.queryDate),
        Expanded(
          child: ListView(
            children: finalCards,
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
