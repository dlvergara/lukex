import 'package:flutter/material.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final providers = new List(3);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double minusConstant = 0.004;

  CocosYLucas providerOne = new CocosYLucas();
  Tkambio providerTwo = new Tkambio();
  JetPeru providerThree = new JetPeru();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    double iconSize = 20;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DefaultTextStyle(
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
              child: FutureBuilder<String>(
                future: this.providerOne.fetchData(),
                // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                      double minus = double.parse(snapshot.data) - minusConstant;
                  List<Widget> children;
                  if (snapshot.hasData) {
                    children = <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: iconSize,
                      ),
                      Text('CocosYLucas: ${snapshot.data}'),
                      Text('CocosYLucas: ${minus}'),
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
                            child: Text('Awaiting result...'),
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
            DefaultTextStyle(
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
              textAlign: TextAlign.center,
              child: FutureBuilder<String>(
                future: this.providerTwo.fetchData(),
                // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                      double minus = double.parse(snapshot.data) -
                          minusConstant;
                      List<Widget> children;
                      if (snapshot.hasData) {
                        children = <Widget>[
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: iconSize,
                          ),
                          Text('Tkambio: ${snapshot.data}'),
                          Text('Tkambio: ${minus}'),
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
                            child: Text('Awaiting result...'),
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
            DefaultTextStyle(
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
              textAlign: TextAlign.center,
              child: FutureBuilder<String>(
                future: this.providerThree.fetchData(),
                // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                      double minus = double.parse(snapshot.data) -
                          minusConstant;
                      List<Widget> children;
                      if (snapshot.hasData) {
                        children = <Widget>[
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: iconSize,
                          ),
                          Text('Jet Peru: ${snapshot.data}'),
                          Text('Jet Peru: ${minus}'),
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
                            child: Text('Awaiting result...'),
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
            const Divider(
              color: Colors.black,
              height: 20,
              thickness: 5,
              indent: 20,
              endIndent: 0,
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
