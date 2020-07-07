import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kafka/kafka.dart';
import 'package:logging/logging.dart';
import 'package:lukex/ProviderInterface.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Util/Database.dart';
import 'package:lukex/pages/GraphPage.dart';

import '../Util/LinearData.dart';

class GraphPageState extends State<GraphPage> {
  List<charts.Series<LinearData, int>> seriesListGlobal = [];

  ///Providers
  List<ProviderInterface> getProviders() {
    CocosYLucas cocosyLucasProvider = new CocosYLucas();
    Tkambio tkambioProvider = new Tkambio();
    JetPeru jetPeruProvider = new JetPeru();
    CambistaInca cambistaProvider = new CambistaInca();

    List<ProviderInterface> list = [
      cocosyLucasProvider,
      tkambioProvider,
      jetPeruProvider,
      cambistaProvider,
    ];
    return list;
  }

  void getDataFromKafka(element) async {
    List<LinearData> list = [];
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);

    var session = Session(['107.170.208.14:9092']);
    var consumer = Consumer<String, String>('simple_consumer_' + element.name,
        StringDeserializer(), StringDeserializer(), session);

    await consumer.subscribe(["lukex_" + element.name]);
    await consumer.seekToBeginning();
    var queue = consumer.poll();
    while (await queue.moveNext()) {
      var records = queue.current;
      print(records);
      /*
        for (var record in records.records) {
          print(
              "[${record.topic}:${record.partition}], offset: ${record.offset}, ${record.key}, ${record.value}, ts: ${record.timestamp}");
          try {
            var jsonDatum = jsonDecode(record.value);
            double exchangeValue = double.parse(jsonDatum['value']);

            var datum = new LinearData(record.key, exchangeValue);
            list.add(datum);
          } on Exception {
            print("Error: " + record.value);
            await consumer.commit();
          }
        }
        */
      //await consumer.commit();
    }
    await session.close();
  }

  ///Build serie all providers
  Future<List<charts.Series<LinearData, int>>> buildSeriesData() async {
    List<ProviderInterface> providers = this.getProviders();
    List<charts.Series<LinearData, int>> seriesList = [];

    var db = new Database();
    var conn = await db.getConnection();

    providers.forEach((element) async {
      List<LinearData> list = [];

      var results = await conn.query(
          'SELECT * FROM exchange '
          'WHERE provider = ? '
          'AND exchange < 10 '
          'ORDER BY `timestamp` '
          'LIMIT 50, 10',
          ["lukex_" + element.name]);
      print(element.name + "-> " + results.length.toString());

      for (var row in results) {
        var dataRow =
            new LinearData(row['timestamp'].toString(), row['exchange']);
        list.add(dataRow);
      }

      var value = new charts.Series<LinearData, int>(
          id: element.name,
          //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          //domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearData sales, _) => sales.sales,
          data: list,
          domainFn: (LinearData datum, int index) {
            return index;
          });
      //..setAttribute(charts.rendererIdKey, 'customArea')

      if (list.length > 0) {
        seriesList.add(value);
      }
    });

    return seriesList;
  }

  @override
  Widget build(BuildContext context) {
    seriesListGlobal.clear();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Lukex - Gráfica'),
      ),
      body: Column(
        children: <Widget>[
          Text('Grafica'),
          Expanded(
              child: FutureBuilder<List<charts.Series<LinearData, int>>>(
                  future: this.buildSeriesData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<charts.Series<LinearData, int>>>
                          snapshot) {
                    Widget element = Text("Cargando");
                    print(snapshot.hasData);
                    print(snapshot.data);
                    print(snapshot.data.length);

                    if (snapshot.hasData && snapshot.data.length > 0) {
                      snapshot.data.forEach((element) {
                        seriesListGlobal.add(element);
                      });
                    }

                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      element = new charts.LineChart(seriesListGlobal,
                          animate: widget.animate,
                          customSeriesRenderers: [
                            new charts.LineRendererConfig(
                              includeLine: true,
                              includePoints: true,
                              customRendererId: 'customArea',
                              includeArea: false,
                              stacked: true,
                              //symbolRenderer: new charts.CustomSymbolRenderer()
                            ),
                          ]);
                    } else {
                      //Loading
                      element = FittedBox(
                        fit: BoxFit.contain,
                        child: CircularProgressIndicator(),
                      );
                    }
                    return element;
                  })),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
