import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class FoodData {
  final String hour;
  final double foodScore;

  FoodData(
    this.hour,
    this.foodScore,
  );
}

class Stats2Page extends StatefulWidget {
  @override
  _Stats2PageState createState() => _Stats2PageState();
}

class _Stats2PageState extends State<Stats2Page> {
  List<dynamic> _data = [];
  List<FoodData> _foodData = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('fakeData');
    setState(() {
      _data = json.decode(jsonData ?? '')['foodInputs'] ?? [];
      // _foodData = _calculateAverageMoodPerHour(_data);
      _foodData = _calculateAverageFoodPerDay(_data);
    });
  }

  List<FoodData> _calculateAverageFoodPerHour(List<dynamic> data) {
    List<FoodData> foodData = [];

    for (int i = 0; i < 24; i++) {
      List<int> foodScoresForHour = [];
      data.forEach((item) {
        DateTime date = DateTime.parse(item['date']);
        if (date.hour == i) {
          foodScoresForHour.add(item['nutrientInfo']['energy']);
        }
      });

      double averageFoodScoreForHour = 0.0;
      if (foodScoresForHour.isNotEmpty) {
        averageFoodScoreForHour = foodScoresForHour.reduce((a, b) => a + b) /
            foodScoresForHour.length;
      }

      foodData.add(FoodData('$i:00', averageFoodScoreForHour));
    }

    return foodData;
  }

  List<FoodData> _calculateAverageFoodPerDay(List<dynamic> data) {
    List<FoodData> foodData = [];

    // Initialize an empty list to keep track of food scores for each day of the week
    List<List<int>> foodScoresForDayOfWeek = List.generate(7, (_) => []);

    data.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int dayOfWeek = date.weekday % 7;
      foodScoresForDayOfWeek[dayOfWeek].add(item['nutrientInfo']['energy']);
    });

    for (int i = 0; i < 7; i++) {
      double averageFoodScoreForDay = 0.0;
      if (foodScoresForDayOfWeek[i].isNotEmpty) {
        averageFoodScoreForDay =
            foodScoresForDayOfWeek[i].reduce((a, b) => a + b) /
                foodScoresForDayOfWeek[i].length;
      }

      // Use the DateFormat package to format the day of the week as a string
      String dayOfWeekString =
          DateFormat('EEEE').format(DateTime.now().add(Duration(days: i)));
      foodData.add(FoodData(dayOfWeekString, averageFoodScoreForDay));
    }
    return foodData;
  }

  // List<charts.Series<dynamic, String>> _createData() {
  //   return [
  //     charts.Series<dynamic, String>(
  //       id: 'Mood',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (dynamic moodData, _) => moodData.hour,
  //       measureFn: (dynamic moodData, _) => moodData.moodScore,
  //       data: _foodData,
  //       labelAccessorFn: (dynamic moodData, _) =>
  //           moodData.moodScore != 0.0 ? '${moodData.moodScore.toStringAsFixed(2)}' : '',
  //     ),
  //   ];
  // }
  // Returns a numerical value for each day of the week (Monday=1, Tuesday=2, etc.)
  int _getDayOfWeekNumber(String dayOfWeek) {
    switch (dayOfWeek) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 0;
    }
  }

  List<charts.Series<FoodData, String>> _createData() {
    // Sort the data by day of the week starting from Monday
    _foodData.sort((a, b) =>
        _getDayOfWeekNumber(a.hour).compareTo(_getDayOfWeekNumber(b.hour)));
    return [
      charts.Series<FoodData, String>(
        id: 'Food',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromRGBO(255, 173, 155, 1), // peachy pink color
        ),
        domainFn: (FoodData foodData, _) => foodData.hour,
        measureFn: (FoodData foodData, _) => foodData.foodScore,
        data: _foodData,
        labelAccessorFn: (FoodData foodData, _) => foodData.foodScore != 0.0
            ? '${foodData.foodScore.toStringAsFixed(2)}'
            : '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Storage'),
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Center(
            child: Container(
              width: 500,
              height: 320,
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
              child: charts.BarChart(
                _createData(),
                animate: true,
                animationDuration: Duration(milliseconds: 500),
                barRendererDecorator: new charts.BarLabelDecorator<String>(
                  insideLabelStyleSpec: charts.TextStyleSpec(
                    color: charts.ColorUtil.fromDartColor(Colors.grey),
                    fontSize: 8,
                  ),
                ),
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 0,
                    labelAnchor: charts.TickLabelAnchor.centered,
                    labelJustification: charts.TickLabelJustification.outside,
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 12,
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
                ),
                defaultRenderer: charts.BarRendererConfig(
                  cornerStrategy: const charts.ConstCornerStrategy(
                    8,
                  ), // set the corner rounding strategy to round to 8 pixels
                  barRendererDecorator: charts.BarLabelDecorator<String>(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
