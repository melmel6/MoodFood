import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Mood { awful, sad, meh, happy, amazing, none }

class TodaysInputsCard extends StatefulWidget {
  const TodaysInputsCard({
    Key? key,
  }) : super(key: key);

  @override
  _TodaysInputsCardState createState() => _TodaysInputsCardState();
}

class _TodaysInputsCardState extends State<TodaysInputsCard> {
  List<Map<String, dynamic>> _moodInputsFuture = [];
  List<Map<String, dynamic>> _foodInputsFuture = [];
  Mood? _MorningMood = Mood.none;
  Mood? _AfternoonMood = Mood.none;
  Mood? _EveningMood = Mood.none;
  Mood? _NightMood = Mood.none;

  Future<List<Map<String, dynamic>>> getMoodInputs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDataFood = prefs.getString('moodInputs');

    List<dynamic> inputs = json.decode(jsonDataFood ?? '') ?? [];

    DateTime now = DateTime.now();
    String today = now.toString().substring(0, 10);
    List<Map<String, dynamic>> todaysInputs = inputs
        .where((input) => input['date'].toString().substring(0, 10) == today)
        .toList()
        .cast<Map<String, dynamic>>();

    Map<String, Mood> moods = assignMoods(todaysInputs);
    Mood? MorningMood = moods['morning'];
    Mood? AfternoonMood = moods['afternoon'];
    Mood? EveningMood = moods['evening'];
    Mood? NightMood = moods['night'];

    setState(() {
      _MorningMood = MorningMood;
      _AfternoonMood = AfternoonMood;
      _EveningMood = EveningMood;
      _NightMood = NightMood;
    });

    return todaysInputs;
  }

  @override
  void initState() {
    super.initState();
    getMoodInputs();
  }

  static Future<List<Map<String, dynamic>>> getFoodInputs() async {
    String jsonData = await rootBundle.loadString('assets/fake_data.json');
    Map<String, dynamic> data = jsonDecode(jsonData);
    List<dynamic> inputs = data['foodInputs'];
    DateTime now = DateTime.now();
    String today = now.toString().substring(0, 10);
    List<Map<String, dynamic>> todaysInputs = inputs
        .where((input) => input['date'].toString().substring(0, 10) == today)
        .toList()
        .cast<Map<String, dynamic>>();
    return todaysInputs;
  }

  Map<String, Mood> assignMoods(moodInputs) {
    var morningMoodData = moodInputs.firstWhere(
        (input) => input['moodTime'] == 'Morning',
        orElse: () => <String, dynamic>{});

    var afternoonMoodData = moodInputs.firstWhere(
        (input) => input['moodTime'] == 'Afternoon',
        orElse: () => <String, dynamic>{});

    var eveningMoodData = moodInputs.firstWhere(
        (input) => input['moodTime'] == 'Evening',
        orElse: () => <String, dynamic>{});

    var nightMoodData = moodInputs.firstWhere(
        (input) => input['moodTime'] == 'Night',
        orElse: () => <String, dynamic>{});

    var morning = morningMoodData.isNotEmpty
        ? Mood.values[morningMoodData['mood']]
        : Mood.none;
    var afternoon = afternoonMoodData.isNotEmpty
        ? Mood.values[afternoonMoodData['mood']]
        : Mood.none;
    var evening = eveningMoodData.isNotEmpty
        ? Mood.values[eveningMoodData['mood']]
        : Mood.none;
    var night = nightMoodData.isNotEmpty
        ? Mood.values[nightMoodData['mood']]
        : Mood.none;

    return {
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'night': night
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Moods',
                style: TextStyle(
                  //fontSize: 12,
                  fontFamily: 'Montserrat', // Add this
                  // fontWeight: FontWeight.normal,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodWidget('Morning', _getMoodEmoji(_MorningMood)),
                  _buildMoodWidget('Afternoon', _getMoodEmoji(_AfternoonMood)),
                  _buildMoodWidget('Evening', _getMoodEmoji(_EveningMood)),
                  _buildMoodWidget('Night', _getMoodEmoji(_NightMood)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodWidget(String title, String imagePath) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            //fontSize: 12,
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        SvgPicture.asset(
          imagePath,
          width: 40,
          height: 40,
        ),
      ],
    );
  }

  String _getMoodEmoji(Mood? mood) {
    switch (mood) {
      case Mood.awful:
        return '/svg/awful.svg';
      case Mood.sad:
        return '/svg/sad.svg';
      case Mood.meh:
        return '/svg/meh.svg';
      case Mood.happy:
        return '/svg/happy.svg';
      case Mood.amazing:
        return '/svg/super.svg';
      default:
        return '';
    }
  }
}
