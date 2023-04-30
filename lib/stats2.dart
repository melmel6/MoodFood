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

class MoodData {
  final String hour;
  final double moodScore;

  MoodData(
    this.hour,
    this.moodScore,
  );
}

class Stats2Page extends StatefulWidget {
  @override
  _Stats2PageState createState() => _Stats2PageState();
}

class _Stats2PageState extends State<Stats2Page> {
  List<dynamic> _dataMood = [];
  List<dynamic> _dataFood = [];

  List<FoodData> _foodDataDay = [];
  List<FoodData> _foodDataHour = [];
  List<MoodData> _moodDataHour = [];
  List<MoodData> _moodDataDay = [];
  bool _isDaySelected = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('fakeData');
    setState(() {
      _dataFood = json.decode(jsonData ?? '')['foodInputs'] ?? [];
      _foodDataHour = _calculateAverageFoodPerHour(_dataFood);
      _foodDataDay = _calculateAverageFoodPerDay(_dataFood);

      _dataMood = json.decode(jsonData ?? '')['moodInputs'] ?? [];
      _moodDataHour = _calculateAverageMoodPerHour(_dataMood);
      _moodDataDay = _calculateAverageMoodPerDay(_dataMood);
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

      foodData.add(FoodData('$i h', averageFoodScoreForHour));
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

  List<MoodData> _calculateAverageMoodPerHour(List<dynamic> data) {
    List<MoodData> moodData = [];

    for (int i = 0; i < 24; i++) {
      List<int> moodScoresForHour = [];
      data.forEach((item) {
        DateTime date = DateTime.parse(item['date']);
        if (date.hour == i) {
          moodScoresForHour.add(item['mood']);
        }
      });

      double averageMoodScoreForHour = 0.0;
      if (moodScoresForHour.isNotEmpty) {
        averageMoodScoreForHour = moodScoresForHour.reduce((a, b) => a + b) / moodScoresForHour.length;
      }

      moodData.add(MoodData('$i h', averageMoodScoreForHour));
    }

    return moodData;
  }

  List<MoodData> _calculateAverageMoodPerDay(List<dynamic> data) {
    List<MoodData> moodData = [];
    
    // Initialize an empty list to keep track of mood scores for each day of the week

    List<List<int>> moodScoresForDayOfWeek = List.generate(7, (_) => []);

    data.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int dayOfWeek = date.weekday - 1; // Convert from 1-7 to 0-6
      moodScoresForDayOfWeek[dayOfWeek].add(item['mood']);
    });

    
    for (int i = 0; i < 7; i++) {
      double averageMoodScoreForDay = 0.0;
      if (moodScoresForDayOfWeek[i].isNotEmpty) {
        averageMoodScoreForDay = moodScoresForDayOfWeek[i].reduce((a, b) => a + b) / moodScoresForDayOfWeek[i].length;
      }
      
      // Use the DateFormat package to format the day of the week as a string
      String dayOfWeekString = DateFormat('EEEE').format(DateTime.now().add(Duration(days: i)));
      moodData.add(MoodData(dayOfWeekString, averageMoodScoreForDay));
    }

    return moodData;
  }

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

  List<charts.Series<FoodData, String>> _createDataDayFood() {
    // Sort the data by day of the week starting from Monday
    _foodDataDay.sort((a, b) =>
        _getDayOfWeekNumber(a.hour).compareTo(_getDayOfWeekNumber(b.hour)));
    return [
      charts.Series<FoodData, String>(
        id: 'Food',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromARGB(255, 252, 188, 173), // peachy pink color
        ),
        domainFn: (FoodData foodData, _) => foodData.hour,
        measureFn: (FoodData foodData, _) => foodData.foodScore,
        data: _foodDataDay,
        labelAccessorFn: (FoodData foodData, _) => foodData.foodScore != 0.0
            ? '${foodData.foodScore.toStringAsFixed(0)}'
            : '',
      ),
    ];
  }

  List<charts.Series<FoodData, String>> _createDataHourFood() {
    return [
      charts.Series<FoodData, String>(
        id: 'Food',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromARGB(255, 252, 188, 173), // peachy pink color
        ),
        domainFn: (FoodData foodData, _) => foodData.hour,
        measureFn: (FoodData foodData, _) => foodData.foodScore,
        data: _foodDataHour,
        labelAccessorFn: (FoodData foodData, _) => foodData.foodScore != 0.0
            ? '${foodData.foodScore.toStringAsFixed(0)}'
            : '',
      ),
    ];
  }

  List<charts.Series<MoodData, String>> _createDataDayMood() {
    // Sort the data by day of the week starting from Monday
    _moodDataDay.sort((a, b) => _getDayOfWeekNumber(a.hour).compareTo(_getDayOfWeekNumber(b.hour)));

    return [
      charts.Series<MoodData, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromARGB(255, 241, 134, 110), // peachy pink color
        ),
        domainFn: (MoodData moodData, _) => moodData.hour,
        measureFn: (MoodData moodData, _) => moodData.moodScore,
        data: _moodDataDay,
        labelAccessorFn: (MoodData moodData, _) =>
            moodData.moodScore != 0.0 ? '${moodData.moodScore.toStringAsFixed(0)}' : ''
      ),
    ];
  }

  List<charts.Series<MoodData, String>> _createDataHourMood() {
    return [
      charts.Series<MoodData, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromARGB(255, 241, 134, 110), // peachy pink color
        ),
        domainFn: (MoodData moodData, _) => moodData.hour,
        measureFn: (MoodData moodData, _) => moodData.moodScore,
        data: _moodDataHour,
        labelAccessorFn: (MoodData moodData, _) =>
            moodData.moodScore != 0.0 ? '${moodData.moodScore.toStringAsFixed(0)}' : ''
      ),
    ];
  }

  Widget _buildToggleButton(bool isSelected, String text) {
    return ToggleButtons(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Day',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hour',
            style: TextStyle(
              color: isSelected ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ],
      isSelected: [isSelected, !isSelected],
      onPressed: (int newIndex) {
        setState(() {
          _isDaySelected = newIndex == 0;
        });
      },
      borderRadius: BorderRadius.circular(30),
      color:  Color.fromRGBO(255, 173, 155, 1),
      selectedColor:  Color.fromRGBO(255, 173, 155, 1),
      fillColor:  Color.fromRGBO(255, 173, 155, 1),
      selectedBorderColor:  Color.fromRGBO(255, 173, 155, 1),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  Widget _buildChart(isMood){
    return charts.BarChart(
      _isDaySelected ? (isMood? _createDataDayMood() : _createDataDayFood()) : (isMood? _createDataHourMood() : _createDataHourFood()),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildToggleButton(_isDaySelected, 'Day'),
                ],
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Container(
                width: 750,
                height: 400,
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
                child: _buildChart(false)
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Container(
                width: 750,
                height: 400,
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
                child: _buildChart(true)
              ),
            ),
            
          ],
        ),
      ),
    );
  }

}
