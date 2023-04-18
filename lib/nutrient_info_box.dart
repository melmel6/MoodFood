import 'package:flutter/material.dart';

class NutrientInfoBox extends StatelessWidget {
  final String protein;
  final String fat;
  final String carbs;
  final String energy;

  const NutrientInfoBox({
    Key? key,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.energy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Energy'),
                  SizedBox(height: 5),
                  Text('$energy kcal'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Protein'),
                  SizedBox(height: 5),
                  Text('$protein g'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fat'),
                  SizedBox(height: 5),
                  Text('$fat g'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Carbs'),
                  SizedBox(height: 5),
                  Text('$carbs g'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
