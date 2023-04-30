import 'package:flutter/material.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:mood_food/mood_input_page.dart';
import 'package:mood_food/radio_buttons.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mood_food/radio_buttons_mood.dart';
import 'package:mood_food/view_mood_per_day.dart';

class MoodInputTabs extends StatefulWidget {
  @override
  _MoodInputTabsState createState() => _MoodInputTabsState();
}

class _MoodInputTabsState extends State<MoodInputTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  String? _selectedMoodTime;
  int? _selectedMood;



  void _handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDataMood= prefs.getString('moodInputs');
    List<dynamic> moodList = json.decode(jsonDataMood ?? '') ?? [];

    Map<String, dynamic> moodData = {
        'moodTime': _selectedMoodTime,
        'date': DateTime.now().toIso8601String(),
        'mood': _selectedMood
      };

    moodList.add(moodData);
    await prefs.setString('moodInputs', json.encode(moodList));

    _showSuccessDialog(context);
  }

void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            SizedBox(height: 20),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your mood has been saved',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white, // sets the button's background color
            ),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      if (_currentTabIndex == 0) {
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log your mood'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Select a time'),
            Tab(text: 'Choose your mood'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // content of tab 1
          MoodTimeOptions(onselectedMoodTime: (value) {
            // update the selected value in the parent's state
            setState(() {
              _selectedMoodTime = value;
            });
          },
          initialValue: _selectedMoodTime, // pass the selected meal value as the initialValue parameter
          ),
          // content of tab 2
         MoodInputPage(
          selectedMoodTime: _selectedMoodTime,
          onMoodAdded: (value) {
            // update the selected value in the parent's state
            setState(() {
              _selectedMood = value;
            });
         })
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentTabIndex == 0
                  ? null // disable back button on first tab
                  : () {
                      setState(() {
                        _tabController.animateTo(_currentTabIndex - 1);
                      });
                    },
              child: Text('Back'),
            ),
            ElevatedButton(
              onPressed: _currentTabIndex == 0 && _selectedMoodTime == null
                  ? null // disable next button on first tab if meal time not set
                  : _currentTabIndex == 1 && _selectedMood == null
                      ? null // disable next button on second tab if no meal is selected
                      : _currentTabIndex == 1 ? _handleSubmit : () {
                          setState(() {
                            _tabController.animateTo(_currentTabIndex + 1);
                          });
                        },
              child: Text(_currentTabIndex == 1 ? 'Submit' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}