import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHandler {
  final String appId = "bdef4b20";
  final String appKey = "a0870def86868149e4f6ef3ab6a423db";
  final String baseUrl = "https://api.edamam.com/api/food-database/v2/parser";

  Future<dynamic> getFood(String query) async {
    final url = Uri.parse("$baseUrl?app_id=$appId&app_key=$appKey&ingr=$query&nutrition-type=cooking");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search recipes');
    }
  }
}
