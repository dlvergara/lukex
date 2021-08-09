import 'package:audioplayer/audioplayer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/MainProvider.dart';
import 'package:lukex/Util/ProviderGenerator.dart';
import 'package:lukex/Util/Util.dart';
import 'package:lukex/pages/ConfigReferenceValue.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:workmanager/workmanager.dart';
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
  AudioPlayer audioPlugin = AudioPlayer();
  ProviderGenerator gen = new ProviderGenerator();
  Util util = new Util();

  ConfigReferenceValuePage configReference = new ConfigReferenceValuePage(
    title: 'Lukex - Gráfica',
    animate: true,
  );

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
      util.saveToLocalStorage(this.minValue);
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
      AsyncSnapshot<String> snapshot, MainProvider provider) {
    List<Widget> children;
    double exchangeValue = 0.0;
    util.sendToStorage(provider.name, snapshot.data);
    Color fontColor = Colors.grey;

    Widget logo = gen.getLogo(provider);

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
          leading: logo,
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
          leading: logo,
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
      AsyncSnapshot<String> snapshot, MainProvider provider) {
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
  Future<void> getValues() async {
    this.cards = [];
    this.dataCollection = [];
    this.queryDate = new DateTime.now().toString();

    List<dynamic> providerCollection = await gen.GetProviders();

    providerCollection.forEach((provider) {
      //print("Provider to build: " + provider.name);
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

    double previousValue = util.getFromLocalStorage();

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
      cron.schedule(Schedule.parse('*/15 * * * *'), () async {
        print('every 10 minutes');
        this.getValues().then((value) {
          setState(() {});

          double previousValue = util.getFromLocalStorage();
          print(previousValue.toString());
          print(this.minValue);
          if (previousValue > 0 && this.minValue < previousValue) {
            //ALERT!
            util.saveToLocalStorage(this.minValue);
            this.audioPlugin.play(alarmSound);
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

      this.dataCollection = [];
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Lukex - Configuración'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Valor de referencia'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => configReference),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(children: <Widget>[
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //ORDERNAR
            new IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.sort_rounded))
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
