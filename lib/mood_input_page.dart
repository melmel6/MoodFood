import 'package:flutter/material.dart';

class MoodInputPage extends StatefulWidget {
  final String? selectedMoodTime;

  final void Function(dynamic) onMoodAdded;

  const MoodInputPage(
      {Key? key, required this.selectedMoodTime, required this.onMoodAdded})
      : super(key: key);

  @override
  _MoodInputPageState createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  int? _selectedMood;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Awful', 'emoji': '😞', 'color': Colors.red},
    {'label': 'Bad', 'emoji': '🙁', 'color': Colors.orange},
    {'label': 'Meh', 'emoji': '😐', 'color': Colors.yellow},
    {'label': 'Good', 'emoji': '🙂', 'color': Colors.lightGreen},
    {'label': 'Super', 'emoji': '😊', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.bold, // Add this
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _moods.map(
                      (mood) {
                        final isSelected =
                            _selectedMood == _moods.indexOf(mood);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMood = _moods.indexOf(mood);
                            });
                            widget.onMoodAdded(_selectedMood);
                          },
                          child: Transform.scale(
                            scale: isSelected ? 1.2 : 1.0,
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.all(isSelected ? 8.0 : 0.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : null,
                                    borderRadius: BorderRadius.circular(
                                        isSelected ? 50.0 : 0.0),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    mood['emoji'] as String,
                                    style: TextStyle(
                                      fontSize: isSelected ? 56.0 : 48.0,
                                      color: mood['color'] as Color,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  mood['label'] as String,
                                  style: TextStyle(
                                    fontSize: isSelected ? 18.0 : 16.0,
                                    color: mood['color'] as Color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
