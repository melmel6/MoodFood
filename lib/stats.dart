import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

class MoodData {
  final String hour;
  final double moodScore;

  MoodData(this.hour, this.moodScore);
}

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<dynamic> _data = [];
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
      _data = json.decode(jsonData ?? '')['moodInputs'] ?? [];
      _moodDataHour = _calculateAverageMoodPerHour(_data);
      _moodDataDay = _calculateAverageMoodPerDay(_data);

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
        averageMoodScoreForHour = moodScoresForHour.reduce((a, b) => a + b) / moodScoresForHour.length;
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
    switch(dayOfWeek) {
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

  List<charts.Series<MoodData, String>> _createDataDay() {
    // Sort the data by day of the week starting from Monday
    _moodDataDay.sort((a, b) => _getDayOfWeekNumber(a.hour).compareTo(_getDayOfWeekNumber(b.hour)));

    return [
      charts.Series<MoodData, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
        domainFn: (MoodData moodData, _) => moodData.hour,
        measureFn: (MoodData moodData, _) => moodData.moodScore,
        data: _moodDataDay,
        labelAccessorFn: (MoodData moodData, _) =>
            moodData.moodScore != 0.0 ? '${moodData.moodScore.toStringAsFixed(2)}' : ''
      ),
    ];
  }

  List<charts.Series<MoodData, String>> _createDataHour() {
    return [
      charts.Series<MoodData, String>(
        id: 'Mood',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
          Color.fromRGBO(255, 173, 155, 1), // peachy pink color
        ),
        domainFn: (MoodData moodData, _) => moodData.hour,
        measureFn: (MoodData moodData, _) => moodData.moodScore,
        data: _moodDataHour,
        labelAccessorFn: (MoodData moodData, _) =>
            moodData.moodScore != 0.0 ? '${moodData.moodScore.toStringAsFixed(2)}' : ''
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
      color: Colors.pink[400],
      selectedColor: Colors.pink[600],
      fillColor: Colors.pink[600],
      selectedBorderColor: Colors.pink[600],
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
      final chartWidget = _isDaySelected
      ? AspectRatio(
          aspectRatio: 1.5,
          child: charts.BarChart(
            _createDataDay(),
            animate: true,
            barRendererDecorator: new charts.BarLabelDecorator<String>(),
          ),
        )
      : AspectRatio(
          aspectRatio: 1.5,
          child: charts.BarChart(
            _createDataHour(),
            animate: true,
            barRendererDecorator: new charts.BarLabelDecorator<String>(),
          ),
        );


    // responsive
    return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
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
          Expanded(
            child: Stack(
              children: [
                chartWidget,
                Positioned(
                  left: 0,
                  top: -15,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset('/svg/super.svg', width: 40, height: 40),
                      SizedBox(height: 100),
                      SvgPicture.asset('/svg/happy.svg', width: 40, height: 40),
                      SizedBox(height: 100),
                      SvgPicture.asset('/svg/meh.svg', width: 40, height: 40),
                      SizedBox(height: 100),
                      SvgPicture.asset('/svg/sad.svg', width: 40, height: 40),
                      SizedBox(height: 100),
                      SvgPicture.asset('/svg/awful.svg', width: 40, height: 40),
                    ],
                  )
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}






}


