import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';


class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class EmotionalEatingScoreData {
  final DateTime date;
  final double score;

  EmotionalEatingScoreData(this.date, this.score);
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _showWeekly = false;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Future<Map<String, List<dynamic>>> _loadData() async {
    final data = await rootBundle.loadString('assets/fake_data.json');
    final decodedData = jsonDecode(data);
    return {
      'moodInputs': decodedData['moodInputs'],
      'foodInputs': decodedData['foodInputs'],
    };
  }

  DateTime _startOfWeek(DateTime date) {
  int daysToStart = date.weekday - DateTime.monday; // DateTime.monday == 1
  return date.subtract(Duration(days: daysToStart));
  }


  Map<String, List<dynamic>> _groupDataByDate(List<dynamic>? data, bool groupByWeek) {
  if (data == null) {
    return {};
  }

  final dateFormatter = DateFormat('yyyy-MM-dd');
  final Map<String, List<dynamic>> groupedData = {};

  for (final item in data) {
    if (item['date'] != null) {
      final date = DateTime.parse(item['date']);
      final groupDate = groupByWeek ? _startOfWeek(date) : date;
      final formattedDate = dateFormatter.format(groupDate);

      if (!groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate] = [];
      }
      groupedData[formattedDate]?.add(item);
    }
  }

  return groupedData;
}


  double _calculateAverageMoodByPeriod(List<dynamic> data) {
    double sum = 0;
    int count = 0;
    for (final item in data) {
      if (item['mood'] != null) {
        sum += item['mood'];
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  double _calculateAverageEnergyByPeriod(List<dynamic> data) {
    double sum = 0;
    int count = 0;
    for (final item in data) {
      if (item['nutrientInfo'] != null && item['nutrientInfo']['energy'] != null) {
        sum += item['nutrientInfo']['energy'];
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  List<EmotionalEatingScoreData> _calculateEmotionalEatingScore(Map<String, List<dynamic>> moodDataByPeriod, Map<String, List<dynamic>> foodDataByPeriod, bool showWeekly) {
  final List<EmotionalEatingScoreData> scores = [];
  final String dateFormat = showWeekly ? 'w' : 'yyyy-MM-dd';
  final String chartLabel = showWeekly ? 'Weekly Emotional Eating Score' : 'Daily Emotional Eating Score';

  final groupedMoodData = _groupDataByDate(moodDataByPeriod.values.expand((x) => x).toList(), _showWeekly);
  final groupedFoodData = _groupDataByDate(foodDataByPeriod.values.expand((x) => x).toList(), _showWeekly);

  groupedMoodData.forEach((date, moodList) {
    if (groupedFoodData.containsKey(date)) {
      final averageMood = _calculateAverageMoodByPeriod(moodList);
      final averageEnergy = _calculateAverageEnergyByPeriod(groupedFoodData[date]!);

      if (averageMood != 0) {
        double score = averageEnergy / averageMood;
        scores.add(EmotionalEatingScoreData(DateTime.parse(date), score));
      }
    }
  });

  // Sort the list by date
  scores.sort((a, b) => a.date.compareTo(b.date));

  return scores;
  }


  List<charts.Series<EmotionalEatingScoreData, DateTime>> _createChartData(List<EmotionalEatingScoreData> data) {
    return [      charts.Series<EmotionalEatingScoreData, DateTime>(        id: 'EmotionalEatingScore',        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,        domainFn: (EmotionalEatingScoreData scoreData, _) => scoreData.date,        measureFn: (EmotionalEatingScoreData scoreData, _) => scoreData.score,        data: data,      )    ];
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

   List<EmotionalEatingScoreData> _filterDataForCurrentMonth(List<EmotionalEatingScoreData> data) {
    return data.where((scoreData) {
      return scoreData.date.year == _currentMonth.year && scoreData.date.month == _currentMonth.month;
    }).toList();
  }

   @override
  Widget build(BuildContext context) {
    // Declare chartLabel here
    final String chartLabel = _showWeekly ? 'Weekly Emotional Eating Score' : 'Daily Emotional Eating Score';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          Switch(
            value: _showWeekly,
            onChanged: (value) {
              setState(() {
                _showWeekly = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final moodDataByDate = _groupDataByDate(data['moodInputs'] as List<dynamic>?, false);
            final foodDataByDate = _groupDataByDate(data['foodInputs'] as List<dynamic>?, false);
            final emotionalEatingScores = _calculateEmotionalEatingScore(moodDataByDate, foodDataByDate, _showWeekly);
            final filteredData = _filterDataForCurrentMonth(emotionalEatingScores);
            final chartData = _createChartData(filteredData);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: _navigateToPreviousMonth,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text(DateFormat('MMMM yyyy').format(_currentMonth)),
                    IconButton(
                      onPressed: _navigateToNextMonth,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 250.0,
                    child: charts.TimeSeriesChart(
                      chartData,
                      animate: true,
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                      domainAxis: charts.DateTimeAxisSpec(
                        tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
                        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                          day: charts.TimeFormatterSpec(
                            format: 'd',
                            transitionFormat: 'MM/dd/yyyy',
                          ),
                        ),
                        renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.MaterialPalette.gray.shade300,
                          ),
                        ),
                      ),
                      defaultRenderer: charts.LineRendererConfig(
                        includePoints: true,
                      ),
                      behaviors: [
                        charts.ChartTitle(
                          chartLabel,
                          behaviorPosition: charts.BehaviorPosition.top,
                          titleOutsideJustification: charts.OutsideJustification.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error loading data: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}