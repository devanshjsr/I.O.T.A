import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

import '../../models/data_model.dart';
import '../../services/database_services.dart';
import '../../styles.dart';
import 'add_questions.dart';

class CreateQuiz extends StatefulWidget {
  final String subjectId;
  CreateQuiz(this.subjectId);
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

  bool isOkay = true;

  Future<bool> checkClash() async {
    QuerySnapshot quizList =
        await FirebaseFirestore.instance.collection("Quiz_List").get();

    for (int i = 0; i < quizList.docs.length; i++) {
      DocumentSnapshot currQuiz = await FirebaseFirestore.instance
          .collection("Quiz_List")
          .doc(quizList.docs[i].id)
          .get();
      String dur = currQuiz.data()["durationInMins"];
      //print(currQuiz.data().toString());
      DateTime dateTime = DateTime.parse(currQuiz.data()["dateTime"]);
      DateTime endVal = dateTime.add(Duration(minutes: (5 + int.parse(dur))));
      DateTime startVal = dateTime.subtract(Duration(minutes: (5)));

      String endValStr = endVal.toIso8601String().substring(0, 19);
      String startValStr = startVal.toIso8601String().substring(0, 19);
      String endDateTime = DateTime.parse(startDateTime)
          .add(Duration(minutes: int.parse(duration)))
          .toIso8601String()
          .substring(0, 19);

      if (endValStr.compareTo(startDateTime.substring(0, 19)) < 0 ||
          startValStr.compareTo(endDateTime) > 0) {
        return true;
      } else {
        return false;
      }
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
          "subjectId": widget.subjectId,
          "quizId": quizId,
          "title": quizTitle,
          "dateTime": startDateTime,
          "durationInMins": duration,
          "totalQuestions": totalQuestions
        };

        setState(() {
          _loadingIndicator = false;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AddQuestions(dataMap)));
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
                              bool val;
                              checkClash().then((value) {
                                setState(() {
                                  val = value;
                                });
                                val
                                    ? add()
                                    : showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            "Attention!",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          titleTextStyle:
                                              TextStyle(color: Colors.red),
                                          content: Text(
                                              "Your time is clashing with some other Quiz"),
                                          contentTextStyle:
                                              TextStyle(color: Colors.blueGrey),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Ok")),
                                          ],
                                        ),
                                      );
                              });
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
