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

  List<charts.Series<FoodData, String>> _foodforchart = [];

  bool _isDaySelected = true;
  bool _isWeekSelected = true;

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
      _foodDataHour = _calculateAverageFoodPerTimeOfDay(_dataFood);
      _foodDataDay = _calculateAverageFoodPerDay(_dataFood, _selectedMonth);

      _foodforchart = _createBarChartSeries();

      _dataMood = json.decode(jsonDataMood ?? '') ?? [];
      _moodDataHour = _calculateAverageMoodPerTimeOfDay(_dataMood);
      _moodDataDay = _calculateAverageMoodPerDay(_dataMood);

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
        content: Text(content),
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

  List<FoodData> _calculateAverageFoodPerTimeOfDay(List<dynamic> data) {
    List<FoodData> foodData = [];
    Map<String, List<int>> timeOfDayFoodScores = {
      'Morning (5:00 - 12:00)': [],
      'Afternoon (12:00 - 17:00)': [],
      'Evening (17:00 - 21:00)': [],
      'Night (21:00 - 5:00)': [],
    };

    data.forEach((item) {
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

    return foodData;
  }

  List<FoodData> _calculateAverageFoodPerDay(List<dynamic> data, int month) {
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
        averageMoodScoreForHour = moodScoresForHour.reduce((a, b) => a + b) /
            moodScoresForHour.length;
      }

      moodData.add(MoodData('$i h', averageMoodScoreForHour));
    }

    return moodData;
  }

  List<MoodData> _calculateAverageMoodPerTimeOfDay(List<dynamic> data) {
    List<MoodData> moodData = [];

    Map<String, List<int>> timeOfDayMoodScores = {
      'Morning (5:00 - 12:00)': [],
      'Afternoon (12:00 - 17:00)': [],
      'Evening (17:00 - 21:00)': [],
      'Night (21:00 - 5:00)': [],
    };

    data.forEach((item) {
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

  List<charts.Series<FoodData, String>> _createBarChartSeries() {
    return [
      charts.Series<FoodData, String>(
        id: 'Food',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (FoodData data, _) => data.hour,
        measureFn: (FoodData data, _) => data.foodScore,
        data: _foodDataDay,
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

  // Add this function to convert score to emoji
  String scoreToEmoji(double score) {
    if (score < 2) {
      return '😞';
    } else if (score < 4) {
      return '😐';
    } else {
      return '😃';
    }
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

  Widget _buildToggleButton(bool isSelected, String text) {
    return ToggleButtons(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Day',
            style: TextStyle(
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.bold, // Add this
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hour',
            style: TextStyle(
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.bold, // Add this
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
      color: Color.fromRGBO(255, 173, 155, 1),
      selectedColor: Color.fromRGBO(255, 173, 155, 1),
      fillColor: Color.fromRGBO(255, 173, 155, 1),
      selectedBorderColor: Color.fromRGBO(255, 173, 155, 1),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  Widget _buildSummaryToggleButton(bool isSelected) {
    return ToggleButtons(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This Week',
            style: TextStyle(
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.bold, // Add this
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Overall',
            style: TextStyle(
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.bold, // Add this
              color: isSelected ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ],
      isSelected: [isSelected, !isSelected],
      onPressed: (int newIndex) {
        setState(() {
          _isWeekSelected = newIndex == 0;
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
      width: 150,
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
      width: 150,
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

  Widget _buildChart(isMood) {
    return charts.BarChart(
      _isDaySelected
          ? (isMood ? _createDataDayMood() : _createDataDayFood())
          : (isMood ? _createDataHourMood() : _createDataHourFood()),
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
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.grey),
          ),
          labelStyle: charts.TextStyleSpec(
            fontFamily: 'Montserrat', // Add this
            fontWeight: 'Regular', // Add this
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
        _buildInfoContainer(' Average Kcal input', 'overall:', 'this week:',
            Icons.local_dining, '2132', '3011'),
        _buildInfoContainer('Average mood ', 'overall:', 'this week:',
            Icons.mood, '3.1', '1.8'),
        _buildInfoContainer1('Your average emotional score fluctuation:',
            Icons.stacked_line_chart, '12%'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FoodData> foodData =
        _calculateAverageFoodPerDay(_dataFood, _selectedMonth);
    _foodforchart.forEach(
      (food) {
        print('Day: ${food}');
      },
    );
    print('dd ${_selectedMonth}');
    return Scaffold(
      appBar: AppBar(
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
                color: Color.fromARGB(255, 250, 250, 250),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildToggleButton(_isDaySelected, 'Day'),
                          IconButton(
                            icon: Icon(Icons.arrow_left),
                            onPressed: () {
                              setState(() {
                                _selectedMonth--;
                              });
                            },
                          ),
                          Text(
                            DateFormat('MMMM yyyy')
                                .format(DateTime(2023, _selectedMonth)),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_right),
                            onPressed: () {
                              setState(() {
                                _selectedMonth++;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your mood average',
                        style: TextStyle(
                          fontFamily: 'Montserrat', // Add this
                          fontWeight: FontWeight.bold, // Add this
                        ),
                        textAlign: TextAlign.start,
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
                          child: _buildChart(true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
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
                          'Mood-based Food Categories',
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
