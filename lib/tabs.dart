import 'package:flutter/material.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:mood_food/radio_buttons.dart';
import 'package:mood_food/food_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FoodInputTabs extends StatefulWidget {
  @override
  _FoodInputTabsState createState() => _FoodInputTabsState();
}

class _FoodInputTabsState extends State<FoodInputTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  String? _selectedMealTime;

  Map<String, double> nutrientInfo = {};

  // add a list of selected meals
  List<dynamic> _selectedMeals = [];

  void _handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDataFood = prefs.getString('foodInputs');
    List<dynamic> foodList = json.decode(jsonDataFood ?? '') ?? [];

    for (var meal in _selectedMeals) {
      Map<String, dynamic> nutrientData = {
        'mealTime': _selectedMealTime,
        'date': DateTime.now().toIso8601String(),
        'label': meal['label'],
        'measure': meal['measure'],
        'weight': meal['weight'],
        'nutrientInfo': calculateNutrientInfo(
          meal['weight'], // weight in grams
          meal['proteinPer100g'], // protein per 100 g
          meal['fatPer100g'], // fat per 100 g
          meal['carbsPer100g'], // carbs per 100 g
          meal['energyPer100g'], // energy per 100 g
        ),
      };

      foodList.add(nutrientData);
    }

    await prefs.setString('foodInputs', json.encode(foodList));

    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 20),
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat', // Add this
                  fontWeight: FontWeight.normal, // Add this
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your meal has been saved',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat', // Add this
                  fontWeight: FontWeight.normal, // Add this
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // sets the button's background color
              ),
              onPressed: () {
                // Navigator.popUntil(context, ModalRoute.withName('/'));
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      if (_currentTabIndex == 0) {}
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log your meals',
          style: TextStyle(
            // fontSize: 12,
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal, // Add this
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Select a meal time'),
            Tab(text: 'Choose your meal'),
            Tab(
              child: SizedBox(
                height: kToolbarHeight,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Your meal',
                        style: TextStyle(
                          //fontSize: 12,
                          fontFamily: 'Montserrat', // Add this
                          fontWeight: FontWeight.normal, // Add this
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_selectedMeals.length > 0)
                      Positioned(
                        top: 10,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: Text(
                                _selectedMeals.length.toString(),
                                style: TextStyle(
                                  //fontSize: 12,
                                  fontFamily: 'Montserrat', // Add this
                                  //fontWeight: FontWeight.normal, // Add this

                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                  //fontSize: 12,
                  fontFamily: 'Montserrat', // Add this
                  fontWeight: FontWeight.normal, // Add this
                  color: Colors.white),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // content of tab 1
          MealOptions(
            onselectedMealTime: (value) {
              // update the selected value in the parent's state
              setState(() {
                _selectedMealTime = value;
              });
            },
            initialValue:
                _selectedMealTime, // pass the selected meal value as the initialValue parameter
          ),
          // content of tab 2
          FoodInputPage(
            selectedMealTime: _selectedMealTime,
            onMealAdded: (meal) {
              setState(() {
                _selectedMeals.add(meal);
                // _tabController.animateTo(_currentTabIndex + 1);
              });
            },
          ),
          // content of tab 3
          ListView.builder(
            itemCount: _selectedMeals.length,
            itemBuilder: (context, index) {
              final meal = _selectedMeals[index];
              return ListTile(
                  title: Text(
                    meal['label'],
                    style: TextStyle(
                      //fontSize: 12,
                      fontFamily: 'Montserrat', // Add this
                      fontWeight: FontWeight.normal, // Add this
                    ),
                  ),
                  leading: Icon(Icons.close));
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentTabIndex == 0
                  ? null // disable back button on first tab
                  : () {
                      setState(() {
                        _tabController.animateTo(_currentTabIndex - 1);
                      });
                    },
              child: Text(
                'Back',
                style: TextStyle(
                  //fontSize: 12,
                  fontFamily: 'Montserrat', // Add this
                  fontWeight: FontWeight.normal, // Add this
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _currentTabIndex == 0 && _selectedMealTime == null
                  ? null // disable next button on first tab if meal time not set
                  : _currentTabIndex == 1 && _selectedMeals.isEmpty
                      ? null // disable next button on second tab if no meal is selected
                      : _currentTabIndex == 2 && _selectedMeals.isEmpty
                          ? null // disable submit button if no meal is selected
                          : _currentTabIndex == 2
                              ? _handleSubmit
                              : () {
                                  setState(() {
                                    _tabController
                                        .animateTo(_currentTabIndex + 1);
                                  });
                                },
              child: Text(
                _currentTabIndex == 2 ? 'Submit' : 'Next',
                style: TextStyle(
                  //fontSize: 12,
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

Map<String, double> calculateNutrientInfo(
    double weight, double protein, double fat, double carbs, double energy) {
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
