import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:mood_food/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_food/tabs.dart';
import 'package:mood_food/tabs_mood.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mood_food/UserProfilePage.dart';
import 'package:mood_food/StatisticsPage.dart';

class ApiHandler {
  final String appId = "bdef4b20";
  final String appKey = "a0870def86868149e4f6ef3ab6a423db";
  final String baseUrl = "https://api.edamam.com/api/food-database/v2/parser";

  Future<dynamic> getFood(String query) async {
    final url = Uri.parse(
        "$baseUrl?app_id=$appId&app_key=$appKey&ingr=$query&nutrition-type=cooking");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search recipes');
    }
  }
}
