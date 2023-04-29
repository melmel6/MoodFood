import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Chart Demo',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Bar Chart Demo',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: MyEmotionsWidget(emotionSeriesList),
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: Center(
                child: MyBarChartWidget(seriesList),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyBarChartWidget extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  MyBarChartWidget(this.seriesList, {this.animate = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: charts.BarChart(
        seriesList,
        animate: animate,
        vertical: true, // set to true for vertical bars
        defaultRenderer: charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(8),
        ),
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelAnchor: charts.BarLabelAnchor.end,
          labelPosition: charts.BarLabelPosition.inside,
          insideLabelStyleSpec: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.grey),
            fontSize: 1,
          ),
        ),
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelRotation: 0,
            labelAnchor: charts.TickLabelAnchor.centered,
            labelJustification: charts.TickLabelJustification.outside,
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.grey),
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.grey),
            ),
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.ColorUtil.fromDartColor(Colors.grey),
            ),
          ),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            (value) => '${value.toInt()}',
          ),
        ),
      ),
    );
  }
}

List<charts.Series<LinearSales, String>> seriesList = [
  charts.Series<LinearSales, String>(
    id: 'Sales',
    colorFn: (_, __) => charts.ColorUtil.fromDartColor(
      Color.fromRGBO(255, 173, 155, 1), // peachy pink color
    ),
    domainFn: (LinearSales sales, _) => sales.timeRange,
    measureFn: (LinearSales sales, _) => sales.kcalCount,
    data: [
      LinearSales('06:00-12:00', 500),
      LinearSales('12:00-18:00', 2500),
      LinearSales('18:00-00:00', 10000),
      LinearSales('00:00-06:00', 7500),
    ],
  )
];

class LinearSales {
  final String timeRange;
  final int kcalCount;

  LinearSales(this.timeRange, this.kcalCount);
}

class MyEmotionsWidget extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  MyEmotionsWidget(this.seriesList, {this.animate = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: charts.BarChart(
        seriesList,
        animate: animate,
        vertical: true, // set to true for vertical bars
        defaultRenderer: charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(8),
        ),
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelAnchor: charts.BarLabelAnchor.end,
          labelPosition: charts.BarLabelPosition.inside,
          insideLabelStyleSpec: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.grey),
            fontSize: 12,
          ),
        ),
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelRotation: 0,
            labelAnchor: charts.TickLabelAnchor.centered,
            labelJustification: charts.TickLabelJustification.outside,
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.grey),
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.grey),
            ),
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.ColorUtil.fromDartColor(Colors.grey),
            ),
          ),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            (value) => '${value.toInt()}',
          ),
        ),
      ),
    );
  }
}

List<charts.Series<LinearEmotions, String>> emotionSeriesList = [
  charts.Series<LinearEmotions, String>(
    id: 'Emotions',
    colorFn: (_, __) => charts.ColorUtil.fromDartColor(
      Color.fromARGB(255, 248, 68, 98),
    ),
    domainFn: (LinearEmotions emotions, _) => emotions.emotion,
    measureFn: (LinearEmotions emotions, _) => emotions.timeRange,
    data: [
      LinearEmotions('06:00-12:00', 1),
      LinearEmotions('12:00-18:00', 3),
      LinearEmotions('18:00-00:00', 2),
      LinearEmotions('00:00-06:00', 4),
    ],
  )
];

class LinearEmotions {
  final String emotion;
  final int timeRange;

  LinearEmotions(this.emotion, this.timeRange);
}
