import 'package:flutter/material.dart';
import 'package:mood_food/tabs.dart';

class MoodTimeOptions extends StatefulWidget {
  final void Function(String?) onselectedMoodTime;
  final String? initialValue;

  const MoodTimeOptions({Key? key, required this.onselectedMoodTime, this.initialValue}) : super(key: key);

  @override
  _MoodTimeOptionsState createState() => _MoodTimeOptionsState();
}

class _MoodTimeOptionsState extends State<MoodTimeOptions> {
  String? _selectedMoodTime;
  @override
  void initState() {
    super.initState();
    _selectedMoodTime = widget.initialValue;
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          title: Text('Morning',style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Morning',
          groupValue: _selectedMoodTime,
          onChanged: (value) {
            setState(() {
              _selectedMoodTime = value;
            });
            widget.onselectedMoodTime(_selectedMoodTime);
          },
        ),
        RadioListTile(
          title: Text('Afternoon', style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Afternoon',
          groupValue: _selectedMoodTime,
          onChanged: (value) {
            setState(() {
              _selectedMoodTime = value;
            });
            widget.onselectedMoodTime(_selectedMoodTime);
          },
        ),
        RadioListTile(
          title: Text('Evening', style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Evening',
          groupValue: _selectedMoodTime,
          onChanged: (value) {
            setState(() {
              _selectedMoodTime = value;
            });
            widget.onselectedMoodTime(_selectedMoodTime);
          },
        ),
        RadioListTile(
          title: Text('Night', style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Night',
          groupValue: _selectedMoodTime,
          onChanged: (value) {
            setState(() {
              _selectedMoodTime = value;
            });
            widget.onselectedMoodTime(_selectedMoodTime);
          },
        ),
      ],
    );
  }
}

