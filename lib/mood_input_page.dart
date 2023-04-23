import 'package:flutter/material.dart';

class MoodInputPage extends StatefulWidget {
  const MoodInputPage({Key? key}) : super(key: key);

  @override
  _MoodInputPageState createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  int? _selectedMood;
  double _sliderValue = 1;

  final List<Map<String, dynamic>> _moods = [    {'label': 'Awful', 'emoji': '😞', 'color': Colors.red},    {'label': 'Bad', 'emoji': '🙁', 'color': Colors.orange},    {'label': 'Meh', 'emoji': '😐', 'color': Colors.yellow},    {'label': 'Good', 'emoji': '🙂', 'color': Colors.lightGreen},    {'label': 'Super', 'emoji': '😊', 'color': Colors.green},  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How are you?'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Choose a mood:',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _moods.map(
                      (mood) {
                        final isSelected = _selectedMood == _moods.indexOf(mood);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMood = _moods.indexOf(mood);
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                mood['emoji'] as String,
                                style: TextStyle(
                                  fontSize: isSelected ? 56.0 : 48.0,
                                  color: isSelected ? Colors.grey : mood['color'] as Color,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                mood['label'] as String,
                                style: TextStyle(
                                  fontSize: isSelected ? 18.0 : 16.0,
                                  color: isSelected ? Colors.grey : mood['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100.0,
            color: _selectedMood != null ? Colors.green : Colors.grey.shade300,
            child: Center(
              child: _selectedMood != null
                  ? IconButton(
                      onPressed: () {
                        // navigate back to the main screen
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      color: Colors.white,
                      iconSize: 48.0,
                    )
                  : SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
