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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodMood',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'MoodFood'),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _pages = [
    UserProfilePage(),
    StatisticsPage(),
    CalendarPage(),
  ];
  int _counter = 0;

  void _saveFakeDataToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? fakeDataStorage = prefs.getString('fakeData');
    if (fakeDataStorage == null) {
      String jsonData = await rootBundle.loadString('assets/fake_data.json');
      await prefs.setString('fakeData', jsonData);

      print("Loaded fake data");
    } else {
      print("Fake data already exists in local storage");
    }

    _getAllEntriesFromLocalStorage();
  }

  Future<Map<String, dynamic>> _getAllEntriesFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allEntries = {};

    for (String key in prefs.getKeys()) {
      allEntries[key] = prefs.get(key);
    }

    // print(allEntries["fakeData"]);
    print(allEntries["foodInputs"]);
    print(allEntries["moodInputs"]);

    return allEntries;
  }

  @override
  void initState() {
    super.initState();

    _saveFakeDataToLocalStorage();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          // Handle navigation to the selected page
          _onPageTapped(index, context);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
      ),
    );
  }

  int _selectedIndex = 0;

  void _onPageTapped(int index, BuildContext context) {
// Update the selected index
    setState(() {
      _selectedIndex = index;
    });
  }
}

Future<Map<String, dynamic>> getAllEntriesFromLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, dynamic> allEntries = {};

  for (String key in prefs.getKeys()) {
    allEntries[key] = prefs.get(key);
  }

  return allEntries;
}
