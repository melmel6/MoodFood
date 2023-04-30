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
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat', // Add this
              fontWeight: FontWeight.bold, // Add this
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Energy',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$energy kcal',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protein',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$protein g',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fat',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$fat g',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carbs',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$carbs g',
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
