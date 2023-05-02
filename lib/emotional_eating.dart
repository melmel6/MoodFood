import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';

class EmotionaleatingPage extends StatefulWidget {
  const EmotionaleatingPage({Key? key}) : super(key: key);

  @override
  _EmotionaleatingPageState createState() => _EmotionaleatingPageState();
}

class EmotionalEatingScoreData {
  final DateTime date;
  final double score;

  EmotionalEatingScoreData(this.date, this.score);
}

class _EmotionaleatingPageState extends State<EmotionaleatingPage> {
  bool _showWeekly = true;

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

  Map<String, List<dynamic>> _groupDataByDate(
      List<dynamic>? data, bool groupByWeek) {
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
      if (item['nutrientInfo'] != null &&
          item['nutrientInfo']['energy'] != null) {
        sum += item['nutrientInfo']['energy'];
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  List<EmotionalEatingScoreData> _calculateEmotionalEatingScore(
      Map<String, List<dynamic>> moodDataByPeriod,
      Map<String, List<dynamic>> foodDataByPeriod,
      bool showWeekly) {
    final List<EmotionalEatingScoreData> scores = [];

    final String dateFormat = showWeekly ? 'w' : 'yyyy-MM-dd';
    final String chartLabel = showWeekly
        ? 'Emotional Eating Score over the last week'
        : 'Emotional Eating Score over all time';

    final groupedMoodData = _groupDataByDate(
        moodDataByPeriod.values.expand((x) => x).toList(), _showWeekly);
    final groupedFoodData = _groupDataByDate(
        foodDataByPeriod.values.expand((x) => x).toList(), _showWeekly);

    groupedMoodData.forEach((date, moodList) {
      if (groupedFoodData.containsKey(date)) {
        final averageMood = _calculateAverageMoodByPeriod(moodList);
        final averageEnergy =
            _calculateAverageEnergyByPeriod(groupedFoodData[date]!);

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

  List<charts.Series<EmotionalEatingScoreData, DateTime>> _createChartData(
      List<EmotionalEatingScoreData> data) {
    return [
      charts.Series<EmotionalEatingScoreData, DateTime>(
        id: 'EmotionalEatingScore',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (EmotionalEatingScoreData scoreData, _) => scoreData.date,
        measureFn: (EmotionalEatingScoreData scoreData, _) => scoreData.score,
        data: data,
      )
    ];
  }

  List<EmotionalEatingScoreData> _filterLastMonthData(
      List<EmotionalEatingScoreData> data) {
    final lastDate = data.last.date;
    final monthAgo = DateTime(lastDate.year, lastDate.month - 1, lastDate.day);
    return data.where((scoreData) => scoreData.date.isAfter(monthAgo)).toList();
  }

  Widget _buildToggleButton2(bool showWeekly, String text) {
    return ToggleButtons(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This Week',
            style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this

              color: showWeekly ? Colors.white : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Overall',
            style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this

              color: showWeekly ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ],
      isSelected: [showWeekly, !showWeekly],
      onPressed: (int newIndex) {
        setState(() {
          _showWeekly = newIndex == 0;
        });
      },
      borderRadius: BorderRadius.circular(30),
      color: Color.fromRGBO(255, 173, 155, 1),
      selectedColor: Color.fromRGBO(255, 173, 155, 1),
      fillColor: Color.fromRGBO(255, 173, 155, 1),
      selectedBorderColor: Color.fromRGBO(255, 173, 155, 1),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Declare chartLabel here
    final String chartLabel = _showWeekly
        ? 'Emotional Eating Score over the last week'
        : 'Emotional Eating Score over all time';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            //fontSize: 12,
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal, // Add this
          ),
        ),
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final moodDataByDate =
                _groupDataByDate(data['moodInputs'] as List<dynamic>?, false);
            final foodDataByDate =
                _groupDataByDate(data['foodInputs'] as List<dynamic>?, false);
            final emotionalEatingScores = _calculateEmotionalEatingScore(
                moodDataByDate, foodDataByDate, _showWeekly);
            final lastMonthEmotionalEatingScores =
                _filterLastMonthData(emotionalEatingScores);
            final chartData = _createChartData(_showWeekly
                ? lastMonthEmotionalEatingScores
                : emotionalEatingScores);

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 250.0,
                        child: charts.TimeSeriesChart(
                          chartData,
                          animate: true,
                          dateTimeFactory: const charts.LocalDateTimeFactory(),
                          domainAxis: charts.DateTimeAxisSpec(
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
                              titleOutsideJustification:
                                  charts.OutsideJustification.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Show Weekly Data',
                            style: TextStyle(
                              //fontSize: 12,
                              fontFamily: 'Montserrat', // Add this
                              fontWeight: FontWeight.normal, // Add this
                            ),
                          ),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          _buildToggleButton2(_showWeekly, "Show Weekly Data"),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              'Error loading data: ${snapshot.error}',
              style: TextStyle(
                //fontSize: 12,
                fontFamily: 'Montserrat', // Add this
                fontWeight: FontWeight.normal, // Add this
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
