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
import 'package:mood_food/UserProfilePage.dart';
//import 'package:mood_food/AddPage.dart';
import 'package:mood_food/StatisticsPage.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  int? _selectedValue;

  final String _lastEntryDate = '1 May 2023 21:09';
  final String _lastEntryAnswer1 = '5';
  final String _lastEntryAnswer2 =
      "I'm feeling stressed and overwhelmed from work today, and I'm using food as a way to soothe myself.";
  final String _lastEntryAnswer3 =
      'Yes, I had a really difficult project at work that I had to finish by the end of the day, and it was causing me anxiety.';

  List<Widget> _buildBoxes() {
    List<Widget> boxes = [];

    boxes.add(_buildInfoContainer(
      icon: Icons.book,
      title: 'Understanding Emotional Eating',
      info: 'Description 1',
      icon2: Icons.info,
      info2: 'Description 2',
      icon3: Icons.info,
      info3: 'Description 3',
    ));
    boxes.add(_buildInfoContainer(
      icon: Icons.info,
      title: 'Identifying Emotional Triggers',
      info: 'Description 1',
      icon2: Icons.info,
      info2: 'Description 2',
      icon3: Icons.info,
      info3: 'Description 3',
    ));
    boxes.add(_buildInfoContainer(
      icon: Icons.info,
      title: 'Coping Strategies and Techniques',
      info: 'Description 1',
      icon2: Icons.info,
      info2: 'Description 2',
      icon3: Icons.info,
      info3: 'Description 3',
    ));
    boxes.add(_buildInfoContainer(
      icon: Icons.info,
      title: 'Nutrition and Healthy Eating',
      info: 'Description 1',
      icon2: Icons.info,
      info2: 'Description 2',
      icon3: Icons.info,
      info3: 'Description 3',
    ));
    boxes.add(_buildInfoContainer(
      icon: Icons.book,
      title: 'Success Stories and Inspirational Content',
      info: 'Description 1',
      icon2: Icons.info,
      info2: 'Description 2',
      icon3: Icons.info,
      info3: 'Description 3',
    ));
    return boxes;
  }

  Widget _buildGridView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(8),
      itemCount: _buildBoxes().length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: MediaQuery.of(context).size.width *
              0.5, // Adjust the width as needed
          child: _buildBoxes()[index],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color.fromARGB(255, 255, 194, 140),
        title: Text(
          'Journal',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildGridView()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reflect on your emotions and eating habits with this prompt:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM d, y h:mm a').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildQuestionBox(
                    '1. How hungry are you on a scale from 1-10?',
                    DropdownButtonFormField<int>(
                      value: _selectedValue,
                      decoration: InputDecoration(
                        hintText: 'Pick a value',
                        contentPadding: EdgeInsets.all(16),
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              //fontSize: 12,
                              fontFamily: 'Montserrat', // Add this
                              fontWeight: FontWeight.normal, // Add this
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value;
                          _controller1.text = _selectedValue!.toString();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionBox(
                    '2. What emotions are you experiencing right now?',
                    TextField(
                      controller: _controller2,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Answer here...',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionBox(
                    '3. Did you experience any stressful or triggering events today?',
                    TextField(
                      controller: _controller3,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Answer here...',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildLastEntryHeader(),
                  SizedBox(height: 4),
                  _buildLastEntryBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer({
    required IconData icon,
    required String title,
    required String info,
    required IconData icon2,
    required String info2,
    required IconData icon3,
    required String info3,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ExpansionTile(
            title: Text('Learn More'),
            children: [
              ListTile(
                leading: Icon(icon),
                title: Text(
                  info,
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal, // Add this
                  ),
                ),
              ),
              ListTile(
                leading: Icon(icon2),
                title: Text(
                  info2,
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal, // Add this
                  ),
                ),
              ),
              ListTile(
                leading: Icon(icon3),
                title: Text(
                  info3,
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal, // Add this
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBox(String question, Widget inputWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: inputWidget,
        ),
      ],
    );
  }

  Widget _buildLastEntryHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Last Journal Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Navigate to the view all entries page
            },
            child: Text(
              'View all entries',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastEntryBox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text(
                  _lastEntryDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnswerBox('Answer 1:', _lastEntryAnswer1),
                SizedBox(height: 16),
                _buildAnswerBox('Answer 2:', _lastEntryAnswer2),
                SizedBox(height: 16),
                _buildAnswerBox('Answer 3:', _lastEntryAnswer3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerBox(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8),
        Text(
          answer,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
