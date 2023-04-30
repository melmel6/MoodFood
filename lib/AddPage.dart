import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:mood_food/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_food/tabs.dart';
import 'package:mood_food/tabs_mood.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mood_food/stats.dart';
import 'package:mood_food/stats2.dart';
import 'package:mood_food/UserProfilePage.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add',
          style: TextStyle(
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal, // Add this
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodInputTabs(),
                    ),
                  );
                }
                ;
              },
              child: Text(
                'Input a meal',
                style: TextStyle(
                  fontFamily: 'Montserrat', // Add this
                  fontWeight: FontWeight.normal, // Add this
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoodInputTabs(),
                    ),
                  );
                }
                ;
              },
              child: Text(
                'Input your mood',
                style: TextStyle(
                  fontFamily: 'Montserrat', // Add this
                  fontWeight: FontWeight.normal, // Add this
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
