//import 'package:audioplayer/audioplayer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/Helper/LukexCard.dart';
import 'package:lukex/Helper/ad_helper.dart';
import 'package:lukex/Util/ProviderGenerator.dart';
import 'package:lukex/Util/Util.dart';
import 'package:lukex/pages/ConfigReferenceValue.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//import 'package:workmanager/workmanager.dart';
import '../pages/MyHomePage.dart';

class MyHomePageState extends State<MyHomePage> {
  double minusConstant = 0.004;
  double minValue = 10.0;
  final alarmSound = 'http://olimpix.me/bicycle-bell-ding-sound-effect.mp3';
  var cards = [];
  var queryDate = "";
  final cron = Cron();
  String localFilePath = "";

  //AudioPlayer audioPlugin = AudioPlayer();
  ProviderGenerator gen = new ProviderGenerator();
  Util util = new Util();

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  ConfigReferenceValuePage configReference = new ConfigReferenceValuePage(
    title: 'Lukex - Config',
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
      //util.saveToLocalStorage(this.minValue);
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

  // Get values
  Future<void> getValues() async {
    this.cards = [];
    this.queryDate = new DateTime.now().toString();

    List<dynamic> providerCollection = await gen.GetProviders();

    providerCollection.forEach((provider) {
      LukexCard fullCard = new LukexCard(provider);
      this.cards.add([provider.name, fullCard]);
    });
  }

  @override
  void initState() {
    super.initState();

    try {
      MobileAds.instance.initialize();

      // TODO: Initialize _bannerAd
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );

      _bannerAd.load();

      cron.schedule(Schedule.parse('*/15 * * * *'), () async {
        print('every 10 minutes');
        this.getValues().then((value) {
          setState(() {});

          double previousValue = util.getFromLocalStorage();
          print(previousValue.toString());
          print(this.minValue);
          if (previousValue > 0 && this.minValue < previousValue) {
            util.saveToLocalStorage(this.minValue);
            //this.audioPlugin.play(alarmSound);
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

    this.cards.sort((a, b) => (a[1].amount).compareTo(b[1].amount));
    this.cards.forEach((element) {
      finalCards.add(element[1].card);
    });

    String valorRefMessage = '';
    double previousValue = util.getFromLocalStorage();
    if (previousValue > 0) {
      valorRefMessage = "Valor de Ref: " + previousValue.toString();
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
        Text(valorRefMessage),
        Text("Cantidad de proveedores: " + finalCards.length.toString()),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //ORDERNAR
            new IconButton(
                onPressed: () {
                  print('Ordenar!');
                  setState(() {});
                },
                icon: Icon(Icons.sort_rounded)),
          ],
        ),
        Text("Consulta: " + this.queryDate),
        // TODO: Display a banner when ready
        if (_isBannerAdReady)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
          ),
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
