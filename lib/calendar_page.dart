import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mood_food/tabs.dart';
import 'package:mood_food/tabs_mood.dart';
import 'package:mood_food/view_mood_per_day.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List> _events = {}; // add this

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  // Local storage\
  void _getAllEntriesFromLocalStorage() async {
    Map<DateTime, List> events = {};

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDataFood= prefs.getString('foodInputs');

    List<dynamic> _dataFood = json.decode(jsonDataFood ?? '') ?? [];

    for (dynamic data in _dataFood) {
      DateTime date = DateTime.parse(data['date']);
      DateTime beginningOfDay = DateTime(date.year, date.month, date.day);
      events[beginningOfDay] = [
        '$date ${data['label']} (${data['measure']} ${data['weight']} g)'
      ];
    }

    setState(() {
      _events = events;
      print("events");
      print(events);
    });
  }

  @override
  void initState() {
    super.initState();
    _getAllEntriesFromLocalStorage();
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  // DateTime _selectedDay = DateTime.now();
  DateTime? _selectedDay = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              color: Colors.white,
            ),
            child: TableCalendar(
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
              availableCalendarFormats: {
                CalendarFormat.month: '',
              },
              selectedDayPredicate: (day) {
                bool hasEntry = _events.keys.any((key) => isSameDay(key, day));
                // return isSameDay(_selectedDay, day) || hasEntry;
                return hasEntry;
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color.fromARGB(255, 241, 110, 110), width: 2),
                    color: Color.fromARGB(255, 241, 110, 110)),
                selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(255, 241, 134, 110),
                      width: 2,
                    ),
                    color: Color.fromARGB(17, 246, 244, 244).withOpacity(0.1),
                    
                    ),
                  selectedTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                markersMaxCount: 1,
                markersAlignment: Alignment.bottomCenter,
                markerMargin: EdgeInsets.symmetric(horizontal: 2),
                markerDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
          Center(
            child: TodaysInputsCard(),
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

Widget _buildInfoContainer(
    {required IconData icon, required String title, required String info}) {
  return Container(
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
      color: Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(info),
      ],
    ),
  );
}
