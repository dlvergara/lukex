import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kafka/kafka.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Util/StorageMessage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lukex',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Lukex'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final providers = new List(3);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double minusConstant = 0.004;

  CocosYLucas cocosyLucasProvider = new CocosYLucas();
  Tkambio tkambioProvider = new Tkambio();
  JetPeru jetPeruProvider = new JetPeru();

  Future<void> _sendToStorage(String provider, String data) async {
    final now = new DateTime.now();
    String formatter = DateFormat('y-M-d_H:m:s').format(now);

    var config = new ProducerConfig(bootstrapServers: ['107.170.208.14:9092']);
    var producer = new Producer<String, String>(
        new StringSerializer(), new StringSerializer(), config);

    StorageMessage msg = new StorageMessage(data, formatter);
    String message = jsonEncode(msg);
    //print(message);

    var record = new ProducerRecord("lukex_" + provider, 0, formatter, message);
    producer.add(record);
    var result = await record.result;
    //print(result);
    await producer.close();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 20;

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
                  List<Widget> children;
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    _sendToStorage("CocosyLucas", snapshot.data);
                    children = <Widget>[
                      ListTile(
                        leading: FlutterLogo(size: 72.0),
                        title: Text('Cocos y lucas'),
                        subtitle: Text('${snapshot.data}'),
                        trailing: Icon(Icons.more_vert),
                        isThreeLine: true,
                      )
                    ];
                  } else if (snapshot.hasError) {
                    children = <Widget>[
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
                  else {
                    children = <Widget>[
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
                // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    double minus = double.parse(snapshot.data) - minusConstant;
                    _sendToStorage("TKambio", snapshot.data);
                    children = <Widget>[ListTile(
                      leading: FlutterLogo(size: 72.0),
                      title: Text('TKambio'),
                      subtitle: Text('${snapshot.data} / ${minus}'),
                      trailing: Icon(Icons.more_vert),
                      isThreeLine: true,
                    )
                    ];
/*
                    children = <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: iconSize,
                      ),
                    ];
 */
                  } else if (snapshot.hasError) {
                    children = <Widget>[
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
                  } else {
                    children = <Widget>[
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
                // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    double minus = double.parse(snapshot.data) - minusConstant;
                    _sendToStorage("JetPeru", snapshot.data);
                    children = <Widget>[ListTile(
                      leading: FlutterLogo(size: 72.0),
                      title: Text('JetPeru'),
                      subtitle: Text('${snapshot.data} / ${minus}'),
                      trailing: Icon(Icons.more_vert),
                      isThreeLine: true,
                    )
                    ];
                  } else if (snapshot.hasError) {
                    children = <Widget>[
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
                  } else {
                    children = <Widget>[
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
              child: ListTile(
                leading: FlutterLogo(size: 72.0),
                title: Text('You have pushed the button this many times:',),
                subtitle: Text('$_counter', style: Theme
                    .of(context)
                    .textTheme
                    .headline4,),
                trailing: Icon(Icons.more_vert),
                isThreeLine: true,
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
