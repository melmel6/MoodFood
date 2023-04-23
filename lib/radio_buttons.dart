import 'package:flutter/material.dart';
import 'package:mood_food/tabs.dart';

class MealOptions extends StatefulWidget {
  final void Function(String?) onselectedMealTime;
  final String? initialValue;

  const MealOptions({Key? key, required this.onselectedMealTime, this.initialValue}) : super(key: key);

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
          title: Text('Breakfast'),
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
          title: Text('Morning Snack'),
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
          title: Text('Lunch'),
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
          title: Text('Afternoon Snack'),
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
          title: Text('Dinner'),
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
          title: Text('Evening Snack'),
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

