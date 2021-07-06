import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/Providers/Acomo.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/Database.dart';
import 'package:lukex/pages/GraphPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

import '../ProviderInterface.dart';
import '../pages/MyHomePage.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Native called background task: $task");

    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    print(date.toString());

    return Future.value(true);
  });
}

class MyHomePageState extends State<MyHomePage> {
  double minusConstant = 0.004;
  double minValue = 10.0;
  var cards = [];
  var dataCollection = [];
  var queryDate = "";

  GraphPage graphPage = new GraphPage(
    title: 'Lukex - Gráfica',
    animate: true,
  );

  /**
   * Send to database
   */
  Future<void> _sendToStorage(String provider, String data) async {
    var db = new Database();
    var conn = await db.getConnection();
    var insertQuery =
        "INSERT INTO lukex.exchange VALUES (null, NOW(), ?, ?, '--')";
    await conn.query(insertQuery, ["lukex_" + provider, data]);
  }

  //Refresh
  void _incrementCounter() {
    this.getValues().then((value) {
      setState(() {});
    });
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
        switch (name) {
          case 'TuCambista':
            providerList.add(new TuCambista());
            break;
          case 'JetPeru':
            providerList.add(new JetPeru());
            break;
          case 'CambistaInca':
            providerList.add(new CambistaInca());
            break;
          case 'Acomo':
            providerList.add(new Acomo());
            break;
          case 'Tkambio':
            providerList.add(new Tkambio());
            break;
          case 'CocosYLucas':
            providerList.add(new CocosYLucas());
            break;
        }
      }
    } catch (e) {
      print('Printing out the message: $e');
    }

    return providerList;
  }

  // Get values
  Future<void> getValues() async {
    this.cards = [];
    this.dataCollection = [];
    this.queryDate = new DateTime.now().toString();

    List<dynamic> providerCollection = await this.GetProviders();

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

    DateTime now = new DateTime.now();
    DateTime date = new DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    print(date.toString());
    try {
      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      /*
    Workmanager().registerOneOffTask(
      "1", // Ignored on iOS
      "simpleTaskKey", // Ignored on iOS
      initialDelay: Duration(seconds: 3),
      constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: true,
          requiresDeviceIdle: true,
          requiresStorageNotLow: true
      )
      existingWorkPolicy: ExistingWorkPolicy.append
      //inputData: ... // fully supported
    ); //Android only (see below)
    */

      Workmanager().registerPeriodicTask(
        "3",
        'periodicTask',
        frequency: Duration(minutes: 15),
        //initialDelay: Duration(seconds: 10),
      );
    } catch (e) {
      print("------------- Exception -------------");
      print(e);
      print("------------- /Exception -------------");
    }

    this.getValues().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    this.minValue = 10;
    var finalCards = <Widget>[];

    this.cards.forEach((element) {
      finalCards.add(element[1]);
    });

    //print(this.dataCollection);
    if (this.dataCollection.length > 0) {
      //print("Ordenar!");
      finalCards = <Widget>[];

      //print("cantidad 1: " + this.dataCollection.length.toString());
      this.dataCollection.sort((a, b) => a[1].compareTo(b[1]));

      this.dataCollection.forEach((dataElement) {
        for (final cardElement in this.cards) {
          if (dataElement[0] == cardElement[0]) {
            finalCards.add(cardElement[1]);
            break;
          }
        }
      });

      //print("cantidad 2: " + this.dataCollection.length.toString());

      //print(finalCards.length);
      //print('fin ordernar');
      this.dataCollection = [];
    }
    //print(this.dataCollection);

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
            /*
            new RaisedButton(
              child: new Text('Gráfica'),
              onPressed: () {
                print('Saltar a graficas');
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => this.graphPage),
                );
                */
              },
            ),*/
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
