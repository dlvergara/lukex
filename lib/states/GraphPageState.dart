import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/pages/GraphPage.dart';

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    List<charts.Series<LinearSales, int>> seriesList = [
      new charts.Series<LinearSales, int>(
        id: 'Desktop',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: [
          new LinearSales(0, 5),
          new LinearSales(1, 25),
          new LinearSales(2, 100),
          new LinearSales(3, 75),
          new LinearSales(4, 75),
          new LinearSales(5, 75),
          new LinearSales(6, 75),
          new LinearSales(7, 75),
          new LinearSales(8, 75),
        ],
      )..setAttribute(charts.rendererIdKey, 'customArea'),
      new charts.Series<LinearSales, int>(
        id: 'Tablet',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: [
          new LinearSales(0, 10),
          new LinearSales(1, 50),
          new LinearSales(2, 200),
          new LinearSales(3, 150),
          new LinearSales(4, 170),
          new LinearSales(5, 175),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Lukex - Gráfica'),
      ),
      body: Column(
        children: <Widget>[
          Text('Deliver features faster'),
          Text('Deliver features faster'),
          Expanded(
            child: new charts.LineChart(seriesList,
                animate: widget.animate,
                customSeriesRenderers: [
                  new charts.LineRendererConfig(
                      // ID used to link series to this renderer.
                      customRendererId: 'customArea',
                      includeArea: true,
                      stacked: true),
                ]),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
