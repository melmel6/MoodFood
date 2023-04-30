import 'package:flutter/material.dart';
import 'package:mood_food/tabs.dart';

class MealOptions extends StatefulWidget {
  final void Function(String?) onselectedMealTime;
  final String? initialValue;

  const MealOptions(
      {Key? key, required this.onselectedMealTime, this.initialValue})
      : super(key: key);

  @override
  _MealOptionsState createState() => _MealOptionsState();
}

class _MealOptionsState extends State<MealOptions> {
  String? _selectedMealTime;
  @override
  void initState() {
    super.initState();
    _selectedMealTime = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          title: Text(
            'Breakfast',
            style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            ),
          ),
          value: 'Breakfast',
          groupValue: _selectedMealTime,
          onChanged: (value) {
            setState(() {
              _selectedMealTime = value;
            });
            widget.onselectedMealTime(_selectedMealTime);
          },
        ),
        RadioListTile(
          title: Text(
            'Morning Snack',
            style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            ),
          ),
          value: 'Morning Snack',
          groupValue: _selectedMealTime,
          onChanged: (value) {
            setState(() {
              _selectedMealTime = value;
            });
            widget.onselectedMealTime(_selectedMealTime);
          },
        ),
        RadioListTile(
          title: Text(
            'Lunch',
            style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            ),
          ),
          value: 'Lunch',
          groupValue: _selectedMealTime,
          onChanged: (value) {
            setState(() {
              _selectedMealTime = value;
            });
            widget.onselectedMealTime(_selectedMealTime);
          },
        ),
        RadioListTile(
          title: Text('Afternoon Snack',style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Afternoon Snack',
          groupValue: _selectedMealTime,
          onChanged: (value) {
            setState(() {
              _selectedMealTime = value;
            });
            widget.onselectedMealTime(_selectedMealTime);
          },
        ),
        RadioListTile(
          title: Text('Dinner', style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Dinner',
          groupValue: _selectedMealTime,
          onChanged: (value) {
            setState(() {
              _selectedMealTime = value;
            });
            widget.onselectedMealTime(_selectedMealTime);
          },
        ),
        RadioListTile(
          title: Text('Evening Snack', style: TextStyle(
              //fontSize: 12,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.normal, // Add this
            )),
          value: 'Evening Snack',
          groupValue: _selectedMealTime,
          onChanged: (value) {
            setState(() {
              _selectedMealTime = value;
            });
            widget.onselectedMealTime(_selectedMealTime);
          },
        ),
      ],
    );
  }
}
