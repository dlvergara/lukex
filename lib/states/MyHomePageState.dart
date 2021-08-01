import 'package:audioplayer/audioplayer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:lukex/Providers/Acomo.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/MidPointFx.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/Database.dart';
import 'package:lukex/pages/GraphPage.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:workmanager/workmanager.dart';

import '../ProviderInterface.dart';
import '../pages/MyHomePage.dart';

class MyHomePageState extends State<MyHomePage> {
  double minusConstant = 0.004;
  double minValue = 10.0;
  final alarmSound = 'http://olimpix.me/bicycle-bell-ding-sound-effect.mp3';
  var cards = [];
  var dataCollection = [];
  var queryDate = "";
  final cron = Cron();
  String localFilePath;
  final LocalStorage storage = new LocalStorage('lukex.json');
  AudioPlayer audioPlugin = AudioPlayer();

  GraphPage graphPage = new GraphPage(
    title: 'Lukex - Gráfica',
    animate: true,
  );

  _saveToStorage(value) {
    storage.setItem('lukex_min_val_usd', value);
  }

  _clearStorage() async {
    try {
      await storage.clear();
    } catch (e) {
      print("------------- Exception -------------");
      print(e);
      print("------------- /Exception -------------");
    }
  }

  _getFromStorage() {
    double variable = storage.getItem('lukex_min_val_usd');
    if (variable == null) {
      variable = 0;
    }
    return variable;
  }

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

  /*
  static void callbackStaticFunction() {
    Workmanager().executeTask((task, inputData) {
      print("Native called background task: $task");

      DateTime now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);
      print(date.toString());

      return Future.value(true);
    });
  }
  */

  //Refresh
  void _incrementCounter() {
    this.getValues().then((value) {
      _saveToStorage(this.minValue);
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

  List<Widget> getChildren(AsyncSnapshot<String> snapshot, ProviderInterface provider) {
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
      //double minus = exchangeValue - minusConstant;
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

  List<Widget> buildChildren(AsyncSnapshot<String> snapshot, ProviderInterface provider) {
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
        print('Provider from db -> ' + name);
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
          case 'MidPointFx':
            providerList.add(new MidPointFx());
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
      print("Provider to build: " + provider.name);
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

    double previousValue = _getFromStorage();

    if (previousValue > 0) {
      Widget card = Card(
          child: ListTile(
        enabled: true,
        leading: FlutterLogo(size: 72.0),
        title: Text("Valor anterior"),
        subtitle: Text(previousValue.toString()),
        trailing: Icon(Icons.more_vert),
        isThreeLine: true,
      ));
      this.cards.add(['previous', card]);
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      cron.schedule(Schedule.parse('*/10 * * * *'), () async {
        print('every 10 minutes');
        this.getValues().then((value) {
          setState(() {});

          double previousValue = _getFromStorage();
          print(previousValue.toString());
          print(this.minValue);
          if (previousValue > 0 && this.minValue < previousValue) {
            //ALERT!
            _saveToStorage(this.minValue);
            this.audioPlugin.play(alarmSound);
          } else {
            _saveToStorage(this.minValue);
          }
        });
      });
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
                _clearStorage();
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
