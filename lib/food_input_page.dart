import 'package:flutter/material.dart';
import 'package:mood_food/api_handler.dart';
import 'package:mood_food/nutrient_info_box.dart';
import 'package:mood_food/submit_button.dart';



class FoodInputPage extends StatefulWidget {
  const FoodInputPage({Key? key}) : super(key: key);

  @override
  _FoodInputPageState createState() => _FoodInputPageState();
}

class _FoodInputPageState extends State<FoodInputPage> {
  final _apiHandler = ApiHandler();

  
  dynamic _searchResponse;
  String _searchQuery = '';
  List<dynamic> _foods = [];
  List<dynamic> _measures = [];
  dynamic _selectedMeasure;
  dynamic _selectedFoodComplete;
  dynamic _selectedFood;
  List<String> _foodLabels = [];
  String? _selectedLabel;

  Future<void> _searchFood() async {
    if (_searchQuery.isNotEmpty) {
      final response = await _apiHandler.getFood(_searchQuery);
      final foods = response['hints']
        .map<dynamic>((hint) => hint['food'])
        .toSet()
        .toList();
      // Extract unique food labels from response
      final foodLabels = response['hints']
          .map<String>((hint) => hint['food']['label'].toString())
          .toSet()
          .toList();
      setState(() {
        _foodLabels = foodLabels;
        _foods = foods;
        _searchResponse = response['hints']; 
      });
    }
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Input Page'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              hintText: 'Search for food...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _selectedLabel = null;
                  _selectedFood = null; // Reset the selected food when the search query changes
                  _selectedFoodComplete = null;
                  _measures = [];
                  _selectedMeasure = null;
                  _foodLabels = []; // Clear the dropdown list when the search query changes
                });
                _searchFood();
              },
            ),
            if (_foodLabels.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 16),
                child: DropdownButtonFormField<dynamic>(
                  value: _selectedFood,
                  onChanged: (value) {
                    setState(() {
                      _selectedFood = value;
                      _selectedLabel = value['label'];
                      _selectedFoodComplete = _searchResponse.firstWhere((response) => response['food']['foodId'] == _selectedFood['foodId'], orElse: () => null);
                      _measures = _selectedFoodComplete['measures'];
                    });
                    print('Selected Food: $_selectedFood');
                    print('Selected Label: $_selectedLabel');
                    print('Food Object:, $_selectedFoodComplete');
                    print('Measures:, $_measures');
                  },
                  items: _foods
                      .map<DropdownMenuItem<dynamic>>((food) =>
                          DropdownMenuItem<dynamic>(
                            value: food,
                            child: Text(food['label']),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select a food',
                  ),
                  // Set the dropdown button's width to be expanded to avoid overflow
                  isExpanded: true,
                ),
              ),
            if (_measures.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 16),
                child: DropdownButtonFormField<dynamic>(
                  value: _selectedMeasure,
                  onChanged: (value) {
                    setState(() {
                      _selectedMeasure = value;
                    });
                    print('Selected Measure: $_selectedMeasure');
                  },
                  items: _measures
                      .map<DropdownMenuItem<dynamic>>((measure) =>
                          DropdownMenuItem<dynamic>(
                            value: measure,
                            child: Text(measure['label']),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select a measure',
                  ),
                  // Set the dropdown button's width to be expanded to avoid overflow
                  isExpanded: true,
                ),
              ),
            if (_selectedMeasure != null)
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected weight:',
                      style: TextStyle(fontSize: 16),
                    ),
                    CustomBadge(
                      label: _selectedMeasure['weight'].toStringAsFixed(2),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),

            // if (_selectedFood != null) // Add this condition to show the nutrient info box only when a food is selected
            //   NutrientInfoBox(
            //   protein: _selectedFood['nutrients']['PROCNT'].toStringAsFixed(2),
            //   fat: _selectedFood['nutrients']['FAT'].toStringAsFixed(2),
            //   carbs: _selectedFood['nutrients']['CHOCDF'].toStringAsFixed(2),
            //   energy: _selectedFood['nutrients']['ENERC_KCAL'].toStringAsFixed(2),
              
            // ),

            if (_selectedMeasure != null)
              SubmitButton(
                weight: _selectedMeasure['weight'],
                label: _selectedLabel,
                measure:_selectedMeasure['label'],
                proteinPer100g: _selectedFood['nutrients']['PROCNT'],
                fatPer100g: _selectedFood['nutrients']['FAT'],
                carbsPer100g: _selectedFood['nutrients']['CHOCDF'],
                energyPer100g: _selectedFood['nutrients']['ENERC_KCAL']
              ),
          ],
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedFood);
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}


class CustomBadge extends StatelessWidget {
  final String label;

  CustomBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 5),
          Text(
            'g',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}


class SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  SearchBar({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }
}


