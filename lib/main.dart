import 'package:flutter/material.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:mood_food/mood_input_page.dart';
import 'package:mood_food/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodMood',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'MoodFood'),
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
  int _counter = 0;

  Future<Map<String, dynamic>> _getAllEntriesFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allEntries = {};

    for (String key in prefs.getKeys()) {
      allEntries[key] = prefs.get(key);
    }

    print(allEntries);
    return allEntries;
  }

  @override
  void initState() {
    super.initState();
    _getAllEntriesFromLocalStorage();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarPage(),
                  ),
                );
              },
              child: const Text('Open Calendar Page'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 150,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FoodInputPage(),
                                ),
                              );
                            },
                            child: const Text('Food'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MoodInputPage(),
                                ),
                              );
                            },
                            child: const Text('Mood'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: const SizedBox.shrink(),
    );
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
