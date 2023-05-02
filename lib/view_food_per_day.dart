import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TodaysFoodInputsCard extends StatefulWidget {
  const TodaysFoodInputsCard({
    Key? key,
  }) : super(key: key);

  @override
  _TodaysFoodInputsCardState createState() => _TodaysFoodInputsCardState();
}

class _TodaysFoodInputsCardState extends State<TodaysFoodInputsCard> {
  List<Map<String, dynamic>> todaysInputs = [];

  void getFoodInputs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonDataFood = prefs.getString('foodInputs');

    List<dynamic> inputs = json.decode(jsonDataFood ?? '') ?? [];

    DateTime now = DateTime.now();
    String today = now.toString().substring(0, 10);

    todaysInputs = inputs
        .where((input) => input['date'].toString().substring(0, 10) == today)
        .toList()
        .cast<Map<String, dynamic>>();

    print("TODAY FOOD");
    print(todaysInputs);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFoodInputs();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Food',
                style: TextStyle(
                  //fontSize: 12,
                  fontFamily: 'Montserrat', // Add this
                  //fontWeight: FontWeight.normal, // Add this

                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // SizedBox(height: 16),
              Container(
                height: 200, // Adjust the height based on your needs
                child: InputList(inputs: todaysInputs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputList extends StatelessWidget {
  final List<Map<String, dynamic>> inputs;

  const InputList({Key? key, required this.inputs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: inputs.length,
      itemBuilder: (context, index) {
        return InputItem(input: inputs[index]);
      },
    );
  }
}

class InputItem extends StatelessWidget {
  final Map<String, dynamic> input;

  const InputItem({Key? key, required this.input}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        input['label'],
        style: TextStyle(
          //fontSize: 12,
          fontFamily: 'Montserrat', // Add this
          fontWeight: FontWeight.normal,
        ),
      ),
      subtitle: Text('${input['measure']} (${input['weight']} g)',
          style: TextStyle(
            //fontSize: 12,
            fontFamily: 'Montserrat', // Add this
            fontWeight: FontWeight.normal,
          )),
      trailing: Container(
        width: 500,
        child: Table(
          defaultColumnWidth: IntrinsicColumnWidth(),
          columnWidths: {
            0: FlexColumnWidth(0.2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(0.2),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              FaIcon(FontAwesomeIcons.clock, size: 14),
              Text(input['mealTime'],
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal,
                  )),
              FaIcon(FontAwesomeIcons.dumbbell, size: 14),
              Text('Protein: ${input['nutrientInfo']['protein']} g',
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal,
                  )),
              Icon(Icons.fastfood, size: 14),
              Text('   Fat: ${input['nutrientInfo']['fat']} g',
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal,
                  )),
            ]),
            TableRow(children: [
              SizedBox(width: 0),
              SizedBox(width: 0),
              FaIcon(FontAwesomeIcons.wheatAwn, size: 14),
              Text('Carbs: ${input['nutrientInfo']['carbs']} g',
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal,
                  )),
              Icon(Icons.local_fire_department, size: 14),
              Text('   Energy: ${input['nutrientInfo']['energy']} kcal',
                  style: TextStyle(
                    //fontSize: 12,
                    fontFamily: 'Montserrat', // Add this
                    fontWeight: FontWeight.normal,
                  )),
            ]),
          ],
        ),
      ),
    );
  }
}


// class InputItem extends StatelessWidget {
//   final Map<String, dynamic> input;

//   const InputItem({Key? key, required this.input}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(input['label']),
//       subtitle: Text('${input['measure']} (${input['weight']} g)'),
//       trailing: Container(
//         width: 510,
//         child: Table(
//           defaultColumnWidth: IntrinsicColumnWidth(),
//           columnWidths: {
//             0: FlexColumnWidth(0.1),
//             1: FlexColumnWidth(0.1),
//             2: FlexColumnWidth(0.2),
//             3: FlexColumnWidth(0.2),
//             4: FlexColumnWidth(0.2),
//           },
//           children: [
//             TableRow(children: [
//               FaIcon(FontAwesomeIcons.clock, size: 16),
//               Text(input['mealTime']),

//               FaIcon(FontAwesomeIcons.dumbbell, size: 16),
//               Text('Protein: ${input['nutrientInfo']['protein']} g'),

//               Icon(Icons.fastfood, size: 16),
//               Text('Fat: ${input['nutrientInfo']['fat']} g'),
//             ]),
//             TableRow(children: [
//               SizedBox(),
//               SizedBox(),
//               FaIcon(FontAwesomeIcons.wheatAwn, size: 16),
//               Text('Carbs: ${input['nutrientInfo']['carbs']} g'),
//               Icon(Icons.local_fire_department, size: 16),
//               Text('Energy: ${input['nutrientInfo']['energy']} kcal'),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
// }
