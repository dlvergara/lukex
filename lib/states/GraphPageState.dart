import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/MainProvider.dart';
import 'package:lukex/Providers/CambistaInca.dart';
import 'package:lukex/Providers/CocosYLucas.dart';
import 'package:lukex/Providers/JetPeru.dart';
import 'package:lukex/Providers/Tkambio.dart';
import 'package:lukex/Providers/TuCambista.dart';
import 'package:lukex/Util/Database.dart';
import 'package:lukex/pages/GraphPage.dart';

import '../Util/LinearData.dart';

class GraphPageState extends State<GraphPage> {
  List<charts.Series<LinearData, int>> seriesListGlobal = [];
  String _time = "";
  Map<String, num> _measures = [] as Map<String, num>;

  ///Providers
  List<MainProvider> getProviders() {
    CocosYLucas cocosyLucasProvider = new CocosYLucas();
    Tkambio tkambioProvider = new Tkambio();
    JetPeru jetPeruProvider = new JetPeru();
    CambistaInca cambistaProvider = new CambistaInca();
    TuCambista tuCambistaProvider = new TuCambista();

    List<MainProvider> list = [
      cocosyLucasProvider,
      tkambioProvider,
      jetPeruProvider,
      cambistaProvider,
      tuCambistaProvider,
    ];
    return list;
  }

  void getDataFromKafka(element) async {
    /*
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
    */
  }

  ///Build serie all providers
  Future<List<charts.Series<LinearData, int>>> buildSeriesData() async {
    List<MainProvider> providers = this.getProviders();
    List<charts.Series<LinearData, int>> seriesList = [];

    var db = new Database();
    var conn = await db.getConnection();

    providers.forEach((element) async {
      List<LinearData> list = [];

      var results = await conn.query(
          'SELECT * FROM exchange '
          'WHERE provider = ? '
          'AND exchange < 10 '
          'ORDER BY `timestamp` DESC '
          'LIMIT 10 ',
          ["lukex_" + element.name]);
      print(element.name + "-> " + results.length.toString());

      for (var row in results) {
        var dataRow =
            new LinearData(row['timestamp'].toString(), row['exchange']);
        list.add(dataRow);
      }

      /*
      var value = new charts.Series<LinearData, int>(
          id: element.name,
          //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          //domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearData sales, _) => sales.sales,
          data: list;
          domainFn: (LinearData datum, int index) {
            return index;
          }
          );
       */
      //..setAttribute(charts.rendererIdKey, 'customArea')

      if (list.length > 0) {
        //seriesList.add(value);
      }
    });

    return seriesList;
  }

  // Listens to the underlying selection changes, and updates the information
  // relevant to building the primitive legend like information under the
  // chart.
  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    String time = "";
    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.year;
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        //measures[datumPair.series.displayName] = datumPair.datum.sales;
      });
    }

    // Request a build.
    setState(() {
      _time = time;
      _measures = measures;
    });
  }

  @override
  Widget build(BuildContext context) {
    seriesListGlobal.clear();
    final measuresLabel = <Widget>[];

    // If there is a selection, then include the details.
    if (_time != null) {
      measuresLabel.add(new Padding(
          padding: new EdgeInsets.only(top: 5.0),
          child: new Text(_time.toString())
      ));
    }

    //var entries = _measures.values.toList();
    //entries.sort((a,b) => entries[a] - entries[b]);
    //_measures = Map<String, int>.fromEntries(entries);

    _measures?.forEach((String series, num value) {
      measuresLabel.add(new Text('${series}: ${value}'));
    });

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
                        print(snapshot.data!.length);

                        if (snapshot.hasData && snapshot.data!.length > 0) {
                          snapshot.data!.forEach((element) {
                            seriesListGlobal.add(element);
                          });
                        }

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          element = new charts.LineChart(
                            seriesListGlobal,
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
                        ],
                        behaviors: [
                          //new charts.ChartTitle("Value", behaviorPosition: charts.BehaviorPosition.start, titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                        ],
                        selectionModels: [
                          new charts.SelectionModelConfig(
                            type: charts.SelectionModelType.info,
                            changedListener: _onSelectionChanged,
                            //listener: _onSelectionChanged,
                          )
                        ],
                      );
                    } else {
                      //Loading
                      element = FittedBox(
                        fit: BoxFit.contain,
                        child: CircularProgressIndicator(),
                      );
                    }
                    return element;
                  })),
        ] + measuresLabel,
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
