import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:mood_food/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_food/tabs.dart';
import 'package:mood_food/tabs_mood.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mood_food/stats.dart';
import 'package:mood_food/stats2.dart';
import 'package:mood_food/UserProfilePage.dart';
import 'package:mood_food/HomePage.dart';
import 'package:mood_food/StatisticsPage.dart';

class MoodData {
  final String hour;
  final double moodScore;

  MoodData(this.hour, this.moodScore);
}

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<dynamic> _data = [];
  List<MoodData> _moodData = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('fakeData');
    setState(() {
      _data = json.decode(jsonData ?? '')['moodInputs'] ?? [];
      // _moodData = _calculateAverageMoodPerHour(_data);
      _moodData = _calculateAverageMoodPerDay(_data);
    });
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
        averageMoodScoreForHour = moodScoresForHour.reduce((a, b) => a + b) /
            moodScoresForHour.length;
      }

      moodData.add(MoodData('$i:00', averageMoodScoreForHour));
    }

    return moodData;
  }

  List<MoodData> _calculateAverageMoodPerDay(List<dynamic> data) {
    List<MoodData> moodData = [];

    // Initialize an empty list to keep track of mood scores for each day of the week
    List<List<int>> moodScoresForDayOfWeek = List.generate(7, (_) => []);

    data.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int dayOfWeek = date.weekday %
          7; // Modulus operator to ensure Sunday is represented by 0
      moodScoresForDayOfWeek[dayOfWeek].add(item['mood']);
    });

    for (int i = 0; i < 7; i++) {
      double averageMoodScoreForDay = 0.0;
      if (moodScoresForDayOfWeek[i].isNotEmpty) {
        averageMoodScoreForDay =
            moodScoresForDayOfWeek[i].reduce((a, b) => a + b) /
                moodScoresForDayOfWeek[i].length;
      }

      // Use the DateFormat package to format the day of the week as a string
      String dayOfWeekString =
          DateFormat('EEEE').format(DateTime.now().add(Duration(days: i)));
      moodData.add(MoodData(dayOfWeekString, averageMoodScoreForDay));
    }

    return moodData;
  }

  // List<charts.Series<dynamic, String>> _createData() {
  //   return [
  //     charts.Series<dynamic, String>(
  //       id: 'Mood',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (dynamic moodData, _) => moodData.hour,
  //       measureFn: (dynamic moodData, _) => moodData.moodScore,
  //       data: _moodData,
  //       labelAccessorFn: (dynamic moodData, _) =>
  //           moodData.moodScore != 0.0 ? '${moodData.moodScore.toStringAsFixed(2)}' : '',
  //     ),
  //   ];
  // }

  List<charts.Series<MoodData, String>> _createData() {
    return [
      charts.Series<MoodData, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (MoodData moodData, _) => moodData.hour,
        measureFn: (MoodData moodData, _) => moodData.moodScore,
        data: _moodData,
        labelAccessorFn: (MoodData moodData, _) => moodData.moodScore != 0.0
            ? '${moodData.moodScore.toStringAsFixed(2)}'
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
          Expanded(
            child: charts.BarChart(
              _createData(),
              animate: true,
              animationDuration: Duration(milliseconds: 500),
              barRendererDecorator: new charts.BarLabelDecorator<String>(),
              domainAxis: new charts.OrdinalAxisSpec(),
              primaryMeasureAxis: new charts.NumericAxisSpec(
                tickProviderSpec:
                    new charts.BasicNumericTickProviderSpec(zeroBound: false),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.fastfood_outlined),
                          title: Text('Input a meal'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodInputTabs(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.emoji_emotions_outlined),
                          title: Text('Input your mood'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoodInputTabs(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
