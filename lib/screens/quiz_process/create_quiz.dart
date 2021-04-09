import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

import '../../models/data_model.dart';
import '../../services/database_services.dart';
import '../../styles.dart';
import 'add_questions.dart';

class CreateQuiz extends StatefulWidget {
  static const routeName = "/create_quiz_screen";

  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final _formKey = GlobalKey<FormState>();
  String totalQuestions, quizTitle, duration, quizId;
  DatabaseServices dbs = new DatabaseServices();
  bool _loadingIndicator = false;

  DateTime currentDate = DateTime.now();
  var currentTime = TimeOfDay.now();
  String selectedDateTime = "Start Date & Time";
  String startDateTime;

  Future<void> _selectDate(BuildContext context) async {
    print(currentDate);
    var pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null) currentDate = pickedDate;
    _selectTime(context);
  }

  Future<void> _selectTime(BuildContext context) async {
    var pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (pickedTime != null) {
      currentTime = pickedTime;
      DateTime pickedDateTime = DateTime.utc(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          pickedTime.hour,
          pickedTime.minute);
      setState(() {
        selectedDateTime = currentDate.toString().substring(0, 10) +
            " " +
            currentTime.toString().substring(10, 15);
        startDateTime = pickedDateTime.toIso8601String();
        print(selectedDateTime);
      });
    }
  }

  void add() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (selectedDateTime == "Start Date & Time") {
        Fluttertoast.showToast(
            msg: DataModel.ADD_DEADLINE,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setState(() {
          _loadingIndicator = true;
        });

        quizId = randomAlphaNumeric(11);
        Map<String, String> dataMap = {
          "quizId": quizId,
          "title": quizTitle,
          "dateTime": startDateTime,
          "durationInMins": duration,
          "totalQuestions": totalQuestions
        };

        //await dbs.addQuiz(dataMap, quizId);

        setState(() {
          _loadingIndicator = false;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AddQuestions(dataMap)));
          //Navigator.of(context).pushNamed(AddQuestions.routeName, arguments: dataMap); //updated
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingIndicator
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Enter quiz details:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CustomStyle.primaryColor,
                            ),
                          ),
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                          decoration: CustomStyle.customTextFieldDecoration(
                            labelText: 'Quiz Title',
                          ),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value.length == 0) {
                              return "Enter Quiz Title";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) => quizTitle = value,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                          decoration: CustomStyle.customTextFieldDecoration(
                              labelText: "Total Questions"),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (int.tryParse(value) == null) {
                              return "Enter valid number";
                            }
                            if (value.length == 0) {
                              return "Enter Number of Questions";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) => totalQuestions = value,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: CustomStyle.customTextFieldDecoration(
                              labelText: 'Duration (in mins)'),
                          keyboardType: TextInputType.datetime,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (int.tryParse(value) == null) {
                              return "Enter valid duration";
                            }
                            if (value.length == 0) {
                              return "Enter Quiz Duration";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) => duration = value,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomStyle.primaryColor,
                            ),
                            child: IconButton(
                              color: CustomStyle.textLight,
                              icon: Icon(Icons.timelapse),
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            child: Text(
                              selectedDateTime,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: CustomStyle.customElevatedButtonStyle(),
                            onPressed: () {
                              add();
                            },
                            child: Text(
                              'Create Quiz',
                              style: CustomStyle.customButtonTextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
