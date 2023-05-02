import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:charts_common/common.dart' as charts_common;

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

class CustomNumericTickFormatterSpec extends charts.NumericTickFormatterSpec {
  final String Function(num) formatter;

  CustomNumericTickFormatterSpec(this.formatter);

  @override
  charts_common.TickFormatter<num> createTickFormatter(
      charts_common.ChartContext context) {
    return _CustomNumericTickFormatter(formatter);
  }
}

class _CustomNumericTickFormatter extends charts_common.TickFormatter<num> {
  final String Function(num) formatter;

  _CustomNumericTickFormatter(this.formatter);

  @override
  List<String> format(List<num> values, Map<num, String> cache,
      {num? stepSize}) {
    return values.map(formatter).toList();
  }
}

class MoodTickFormatter {
  String format(num value) {
    switch (value.toInt()) {
      case 0:
        return 'Awful';
      case 1:
        return 'Sad';
      case 2:
        return 'Meh';
      case 3:
        return 'Happy';
      case 4:
        return 'Super';
      default:
        return '';
    }
  }
}

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedMonth = DateTime.now().month;
  List<dynamic> _dataMood = [];
  List<dynamic> _dataFood = [];

  List<FoodData> _foodDataDay = [];
  List<FoodData> _foodDataHour = [];
  List<MoodData> _moodDataHour = [];
  List<MoodData> _moodDataDay = [];

  List<FoodData> _foodDataMonth = [];
  List<MoodData> _moodDataMonth = [];

  List<charts.Series<FoodData, String>> _foodforchart = [];

  int _isDaySelected = 0;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDataFood = prefs.getString('foodInputs');
    String? jsonDataMood = prefs.getString('moodInputs');

    setState(() {
      _dataFood = json.decode(jsonDataFood ?? '') ?? [];
      _calculateAverageFoodPerTimeOfDay(_dataFood, _selectedMonth);
      _calculateAverageFoodPerDay(_dataFood, _selectedMonth);
      _calculateAverageFoodPerMonth(_dataFood, _selectedMonth);

      _dataMood = json.decode(jsonDataMood ?? '') ?? [];
      _calculateAverageMoodPerTimeOfDay(_dataMood, _selectedMonth);
      _calculateAverageMoodPerDay(_dataMood, _selectedMonth);
      _calculateAverageMoodPerMonth(_dataMood, _selectedMonth);
    });
  }

  void _showInfoPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal, // Add this
            //color: isSelected ? Colors.grey : Colors.white,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            //fontSize: 12,
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal, // Add this
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Montserrat', // Add this
                fontWeight: FontWeight.normal, // Add this
                //color: isSelected ? Colors.grey : Colors.white,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWithInfoIcon(
      BuildContext context, String title, String info) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.bold, // Add this
            //color: isSelected ? Colors.grey : Colors.white,
          ),
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: () => _showInfoPopup(context, title, info),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 241, 134, 110),
            ),
          ),
        ),
      ],
    );
  }

  void _calculateAverageFoodPerTimeOfDay(List<dynamic> data, int month) {
    List<FoodData> foodData = [];
    Map<String, List<int>> timeOfDayFoodScores = {
      'Morning (5:00 - 12:00)': [],
      'Afternoon (12:00 - 17:00)': [],
      'Evening (17:00 - 21:00)': [],
      'Night (21:00 - 5:00)': [],
    };

    // Filter the data to only include items for the specified month
    List<dynamic> monthData = data.where((item) {
      DateTime date = DateTime.parse(item['date']);
      return date.month == month;
    }).toList();

    monthData.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      String timeOfDay;

      if (date.hour >= 5 && date.hour < 12) {
        timeOfDay = 'Morning (5:00 - 12:00)';
      } else if (date.hour >= 12 && date.hour < 17) {
        timeOfDay = 'Afternoon (12:00 - 17:00)';
      } else if (date.hour >= 17 && date.hour < 21) {
        timeOfDay = 'Evening (17:00 - 21:00)';
      } else {
        timeOfDay = 'Night (21:00 - 5:00)';
      }

      timeOfDayFoodScores[timeOfDay]?.add(item['nutrientInfo']['energy']);
    });

    timeOfDayFoodScores.forEach((timeOfDay, foodScores) {
      double averageFoodScore = 0.0;
      if (foodScores.isNotEmpty) {
        averageFoodScore =
            foodScores.reduce((a, b) => a + b) / foodScores.length;
      }

      foodData.add(FoodData(timeOfDay, averageFoodScore));
    });

    setState(() {
      _foodDataHour = foodData;
    });
  }

  void _calculateAverageFoodPerMonth(List<dynamic> data, int month) {
    List<FoodData> foodData = [];

    // Filter the data to only include items for the specified month
    List<dynamic> monthData = data.where((item) {
      DateTime date = DateTime.parse(item['date']);
      return date.month == month;
    }).toList();

    // Initialize an empty list to keep track of food scores for each day of the month
    List<List<int>> foodScoresForDayOfMonth = List.generate(31, (_) => []);

    monthData.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int dayOfMonth = date.day - 1;
      foodScoresForDayOfMonth[dayOfMonth].add(item['nutrientInfo']['energy']);
    });

    for (int i = 0; i < 31; i++) {
      double averageFoodScoreForDay = 0.0;
      if (foodScoresForDayOfMonth[i].isNotEmpty) {
        averageFoodScoreForDay =
            foodScoresForDayOfMonth[i].reduce((a, b) => a + b) /
                foodScoresForDayOfMonth[i].length;
      }

      // Use the DateFormat package to format the day of the month as a string
      String dayOfMonthString = (i + 1).toString();
      foodData.add(FoodData(dayOfMonthString, averageFoodScoreForDay));
    }

    setState(() {
      _foodDataMonth = foodData;
    });
  }

  void _calculateAverageFoodPerDay(List<dynamic> data, int month) {
    List<FoodData> foodData = [];

    // Initialize an empty list to keep track of food scores for each day of the week
    List<List<int>> foodScoresForDayOfWeek = List.generate(7, (_) => []);

    // Filter the data to only include items for the specified month
    List<dynamic> monthData = data.where((item) {
      DateTime date = DateTime.parse(item['date']);
      return date.month == month;
    }).toList();

    monthData.forEach((item) {
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

    setState(() {
      _foodDataDay = foodData;
    });
  }

  void _calculateAverageMoodPerMonth(List<dynamic> data, int month) {
    List<MoodData> moodData = [];

    // Filter the data to only include items for the specified month
    List<dynamic> monthData = data.where((item) {
      DateTime date = DateTime.parse(item['date']);
      return date.month == month;
    }).toList();

    // Initialize an empty list to keep track of food scores for each day of the month
    List<List<int>> moodScoresForDayOfMonth = List.generate(31, (_) => []);

    monthData.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int dayOfMonth = date.day - 1;
      moodScoresForDayOfMonth[dayOfMonth].add(item['mood']);
    });

    for (int i = 0; i < 31; i++) {
      double averageFoodScoreForDay = 0.0;
      if (moodScoresForDayOfMonth[i].isNotEmpty) {
        averageFoodScoreForDay =
            moodScoresForDayOfMonth[i].reduce((a, b) => a + b) /
                moodScoresForDayOfMonth[i].length;
      }

      // Use the DateFormat package to format the day of the month as a string
      String dayOfMonthString = (i + 1).toString();
      moodData.add(MoodData(dayOfMonthString, averageFoodScoreForDay));
    }

    setState(() {
      _moodDataMonth = moodData;
    });
  }

  void _calculateAverageMoodPerTimeOfDay(List<dynamic> data, int month) {
    List<MoodData> moodData = [];

    Map<String, List<int>> timeOfDayMoodScores = {
      'Morning (5:00 - 12:00)': [],
      'Afternoon (12:00 - 17:00)': [],
      'Evening (17:00 - 21:00)': [],
      'Night (21:00 - 5:00)': [],
    };

    // Filter the data to only include items for the specified month
    List<dynamic> monthData = data.where((item) {
      DateTime date = DateTime.parse(item['date']);
      return date.month == month;
    }).toList();

    monthData.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      String timeOfDay;

      if (date.hour >= 5 && date.hour < 12) {
        timeOfDay = 'Morning (5:00 - 12:00)';
      } else if (date.hour >= 12 && date.hour < 17) {
        timeOfDay = 'Afternoon (12:00 - 17:00)';
      } else if (date.hour >= 17 && date.hour < 21) {
        timeOfDay = 'Evening (17:00 - 21:00)';
      } else {
        timeOfDay = 'Night (21:00 - 5:00)';
      }

      timeOfDayMoodScores[timeOfDay]?.add(item['mood']);
    });

    timeOfDayMoodScores.forEach((timeOfDay, moodScores) {
      double averageMoodScore = 0.0;
      if (moodScores.isNotEmpty) {
        averageMoodScore =
            moodScores.reduce((a, b) => a + b) / moodScores.length;
      }

      moodData.add(MoodData(timeOfDay, averageMoodScore));
    });

    setState(() {
      _moodDataHour = moodData;
    });
  }

  void _calculateAverageMoodPerDay(List<dynamic> data, int month) {
    List<MoodData> moodData = [];

    // Initialize an empty list to keep track of mood scores for each day of the week
    List<List<int>> moodScoresForDayOfWeek = List.generate(7, (_) => []);

    // Filter the data to only include items for the specified month
    List<dynamic> monthData = data.where((item) {
      DateTime date = DateTime.parse(item['date']);
      return date.month == month;
    }).toList();

    monthData.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int dayOfWeek = date.weekday - 1; // Convert from 1-7 to 0-6
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

    setState(() {
      _moodDataDay = moodData;
    });
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

  List<charts.Series<FoodData, String>> _createDataMonthFood() {
    return [
      charts.Series<FoodData, String>(
        id: 'Food',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromARGB(255, 252, 188, 173), // peachy pink color
        ),
        domainFn: (FoodData data, _) => data.hour,
        measureFn: (FoodData data, _) => data.foodScore,
        data: _foodDataMonth,
        labelAccessorFn: (FoodData foodData, _) => foodData.foodScore != 0.0
            ? '${foodData.foodScore.toStringAsFixed(0)}'
            : '',
      ),
    ];
  }

  List<charts.Series<MoodData, String>> _createDataMonthMood() {
    return [
      charts.Series<MoodData, String>(
          id: 'Food',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                Color.fromARGB(255, 241, 134, 110), // peachy pink color
              ),
          domainFn: (MoodData data, _) => data.hour,
          measureFn: (MoodData data, _) => data.moodScore,
          data: _moodDataMonth,
          labelAccessorFn: (MoodData data, _) =>
              data.moodScore != 0.0 ? scoreToEmoji(data.moodScore) : ''),
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
    _moodDataDay.sort((a, b) =>
        _getDayOfWeekNumber(a.hour).compareTo(_getDayOfWeekNumber(b.hour)));

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
              moodData.moodScore != 0.0 ? scoreToText(moodData.moodScore) : ''),
    ];
  }

  String scoreToText(double score) {
    if (score <= 1) {
      return 'Awful';
    } else if (score <= 2) {
      return 'Bad';
    } else if (score <= 3) {
      return 'Meh';
    } else if (score <= 4) {
      return 'Happy';
    } else {
      return 'Super';
    }
  }

  String scoreToEmoji(double score) {
    if (score <= 1) {
      return '😢'; // Unicode emoji for sad cry
    } else if (score <= 2) {
      return '😟'; // Unicode emoji for frown
    } else if (score <= 3) {
      return '😐'; // Unicode emoji for meh
    } else if (score <= 4) {
      return '😊'; // Unicode emoji for smile
    } else {
      return '😂'; // Unicode emoji for laugh beam
    }
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
              moodData.moodScore != 0.0 ? scoreToText(moodData.moodScore) : ''),
    ];
  }

  Widget _buildToggleButton(int isSelected) {
    return ToggleButtons(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Day',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: isSelected == 0 ? Colors.white : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Week',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: isSelected == 1 ? Colors.white : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Month',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: isSelected == 2 ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ],
      isSelected: [isSelected == 0, isSelected == 1, isSelected == 2],
      onPressed: (int newIndex) {
        setState(() {
          _isDaySelected = newIndex;
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

  Widget _buildInfoContainer1(String title, IconData icon, String count) {
    return Container(
      width: 250,
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
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
          Icon(
            icon,
            size: 25,
            color: Colors.grey[700],
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.bold, // Add this
              color: Color.fromARGB(255, 255, 117, 75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String title1, String title2, String title3,
      IconData icon, String count1, String count2) {
    return Container(
      width: 250,
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
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
        children: [
          Expanded(
            child: Icon(
              icon,
              size: 25,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              title1,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title2,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      count1,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 117, 75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title3,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      count2,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 117, 75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<charts.Series<dynamic, String>> _getChartData(bool isMood) {
    switch (_isDaySelected) {
      case 0:
        return isMood ? _createDataHourMood() : _createDataHourFood();
      case 1:
        return isMood ? _createDataDayMood() : _createDataDayFood();
      case 2:
        return isMood ? _createDataMonthMood() : _createDataMonthFood();
      default:
        return [];
    }
  }

  Widget _buildChart(isMood) {
    return charts.BarChart(
      _getChartData(isMood),
      animate: true,
      animationDuration: Duration(milliseconds: 500),
      barRendererDecorator: new charts.BarLabelDecorator<String>(
        insideLabelStyleSpec: charts.TextStyleSpec(
          fontFamily: 'Montserrat', // Add this
          fontWeight: 'Bold', // Add this
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
            fontFamily: 'Montserrat', // Add this
            fontWeight: 'Regular', // Add this
            fontSize: 12,
            color: charts.ColorUtil.fromDartColor(Colors.grey),
          ),
        ),
      ),
      // primaryMeasureAxis: charts.NumericAxisSpec(
      //   renderSpec: charts.GridlineRendererSpec(
      //     lineStyle: charts.LineStyleSpec(
      //       color: charts.ColorUtil.fromDartColor(Colors.grey),
      //     ),
      //     labelStyle: charts.TextStyleSpec(
      //       fontFamily: 'Montserrat', // Add this
      //       fontWeight: 'Regular', // Add this
      //       fontSize: 12,
      //       color: charts.ColorUtil.fromDartColor(Colors.grey),
      //     ),
      //   ),
      // ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: isMood
            ? CustomNumericTickFormatterSpec(MoodTickFormatter().format)
            : null,
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.grey),
          ),
          labelStyle: charts.TextStyleSpec(
            fontFamily: 'Montserrat',
            fontWeight: 'Regular',
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

  Widget _buildSummaryStats() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      children: [
        _buildInfoContainer(' Average Kcal input', 'Overall:', 'This week:',
            Icons.local_dining, '2132', '3011'),
        _buildInfoContainer('Average mood ', 'Overall:', 'This week:',
            Icons.mood, '3.1', '1.8'),
        _buildInfoContainer1('Your average emotional score fluctuation:',
            Icons.stacked_line_chart, '12%'),
      ],
    );
  }

  void changeMonth() {
    final selectedDateTime = DateTime(2023, _selectedMonth);
    final selectedMonth = DateFormat('MMMM').format(selectedDateTime);
    print('Selected Month: $selectedMonth');

    _calculateAverageFoodPerTimeOfDay(_dataFood, _selectedMonth);
    _calculateAverageFoodPerDay(_dataFood, _selectedMonth);
    _calculateAverageFoodPerMonth(_dataFood, _selectedMonth);

    _calculateAverageMoodPerTimeOfDay(_dataMood, _selectedMonth);
    _calculateAverageMoodPerDay(_dataMood, _selectedMonth);
    _calculateAverageMoodPerMonth(_dataMood, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color.fromARGB(255, 255, 194, 140),
        title: Text('Statistics',
            style: TextStyle(
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
      ),
      backgroundColor: Colors.grey[200], // Add a background color
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0), // Add padding around the main column
          child: Column(
            children: [
              // _buildSummaryToggleButton(_isWeekSelected),
              _buildSummaryStats(),
              SizedBox(height: 30),
              // Text('Charts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTitleWithInfoIcon(
                          context,
                          'Food Intake and Mood Comparison',
                          "Our multichart is a tool that shows you two different graphs at the same time. One graph shows you how many calories you're eating over time, and the other graph shows you how your mood is changing over time. By looking at these two graphs together, you can see if there are any patterns where your mood changes seem to match up with changes in your calorie intake. For example, if you notice that you tend to eat more when you're feeling sad or stressed, this could be a pattern of emotional eating. "),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_left),
                                onPressed: () {
                                  setState(() {
                                    _selectedMonth--;
                                    changeMonth();
                                  });
                                },
                              ),
                              Text(
                                DateFormat('MMMM yyyy')
                                    .format(DateTime(2023, _selectedMonth)),
                                style: TextStyle(
                                  //fontSize: 12,
                                  fontFamily: 'Montserrat', // Add this
                                  //fontWeight: FontWeight.normal, // Add this

                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_right),
                                onPressed: () {
                                  setState(() {
                                    _selectedMonth++;
                                    changeMonth();
                                  });
                                },
                              ),
                            ],
                          ),
                          _buildToggleButton(_isDaySelected),
                        ],
                      ),
                      Text('Food calories (kcal) by time',
                          style: TextStyle(
                            fontFamily: 'Montserrat', // Add this
                            fontWeight: FontWeight.normal, // Add this
                          )),
                      SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 750,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _buildChart(false),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Mood by time',
                          style: TextStyle(
                            fontFamily: 'Montserrat', // Add this
                            fontWeight: FontWeight.normal, // Add this
                          )),
                      SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 750,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _buildChart(true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Text('Image Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleWithInfoIcon(
                          context,
                          "Mood-based Food Categories",
                          "Our heatmap can help you see if your mood affects the types of food you eat. The chart shows different food types on the right side and moods on the bottom. You'll see lots of colored squares on the chart. Red squares mean you ate more of a food type during that particular mood. So, for example, the more close to red a square is in the 'sad' column of the 'fat' row, that means the more you tended to eat high-fat foods when you were feeling sad."),
                      SizedBox(height: 16),
                      Image.asset(
                        '/heatmap.png',
                        width: 750,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
