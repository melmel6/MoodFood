import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class SubmitButton extends StatefulWidget {
  final double weight;
  final String? label;
  final String measure;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final double energyPer100g;

  const SubmitButton({
    Key? key,
    required this.weight,
    required this.label,
    required this.measure,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    required this.energyPer100g,
  }) : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  Map<String, double> nutrientInfo = {};

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your food intake has been saved.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            nutrientInfo = calculateNutrientInfo(
              widget.weight, // weight in grams
              widget.proteinPer100g, // protein per 100 g
              widget.fatPer100g, // fat per 100 g
              widget.carbsPer100g, // carbs per 100 g
              widget.energyPer100g, // energy per 100 g
            );
          });

          // Save the nutrient info to local storage
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String>? nutrientList = prefs.getStringList('nutrientList') ?? [];

          DateTime now = DateTime.now();
          DateTime proxthes = DateTime.now().subtract(Duration(days: 2));
          DateTime proxthesAtThisTime = DateTime(proxthes.year, proxthes.month, proxthes.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);

          DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
          DateTime yesterdayAtThisTime = DateTime(yesterday.year, yesterday.month, yesterday.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);

          // String formattedDate = '${now.day}-${now.month}-${now.year}';

          Map<String, dynamic> nutrientData = {
            'date': proxthes.toIso8601String(),
            'label': widget.label,
            'measure': widget.measure,
            'weight': widget.weight,
            'nutrientInfo': nutrientInfo
          };

          //Save to local storage
          String nutrientDataJson = jsonEncode(nutrientData);
          nutrientList.add(nutrientDataJson);

          Map<String, dynamic> nutrientData2 = {
            'date': yesterdayAtThisTime.toIso8601String(),
            'label': widget.label,
            'measure': widget.measure,
            'weight': widget.weight,
            'nutrientInfo': nutrientInfo
          };

          //Save to local storage
          String nutrientData2Json = jsonEncode(nutrientData2);
          nutrientList.add(nutrientData2Json);
          await prefs.setStringList('foodEntries', nutrientList);

          _showSuccessDialog(context);
        },
        child: Text('Submit'),
      ),
    );
  }
}

Map<String, double> calculateNutrientInfo(double weight, double protein, double fat, double carbs, double energy) {
  double factor = weight / 100.0;
  double proteinValue = protein * factor;
  double fatValue = fat * factor;
  double carbsValue = carbs * factor;
  double energyValue = energy * factor;

  print('Protein: $proteinValue g');
  print('Fat: $fatValue g');
  print('Carbs: $carbsValue g');
  print('Energy: $energyValue kcal');

  // Create a map of the nutrient values and return it
  return {
    'protein': double.parse(protein.toStringAsFixed(2)),
    'fat': double.parse(fat.toStringAsFixed(2)),
    'carbs': double.parse(carbs.toStringAsFixed(2)),
    'energy': double.parse(energy.toStringAsFixed(2)),
  };
}