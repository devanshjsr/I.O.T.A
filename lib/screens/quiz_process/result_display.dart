import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';
import '../student/student_main_screen.dart';

class ResultDisplay extends StatelessWidget {
  final List<String> answerList;
  final QuerySnapshot questionSnap;
  BuildContext ctx;

  ResultDisplay(this.answerList, this.questionSnap);

  Future<bool> backCommand() {
    Navigator.of(ctx).pushReplacementNamed(StudentMainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    int totalQuestions = 0,
        correctAnswers = 0,
        incorrectAnswers = 0,
        notAttempted = 0;
    if (questionSnap == null) {
      //print("ksks");
    } else {
      totalQuestions = questionSnap.docs.length;
      for (int i = 0; i < totalQuestions; i++) {
        List<String> tempList;
        String temp = questionSnap.docs[i].data()["correctOption"];
        //print(temp);
        tempList = temp.split(" ");
        String correctOptionIndex = (tempList[0] + tempList[1]).toLowerCase();
        String correctOption = questionSnap.docs[i].data()[correctOptionIndex];
        String optionSelected = answerList[i];

        print(optionSelected);
        print(correctOption);

        if (optionSelected == null) {
          notAttempted++;
        } else if (optionSelected.compareTo(correctOption) == 0) {
          correctAnswers++;
        } else {
          incorrectAnswers++;
        }
      }
    }

    Widget getResultTile(String title, String content, Color color) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
        child: TextFormField(
          readOnly: true,
          initialValue: content,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.all(16),
            labelText: title,
            labelStyle: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("QUIZ RESULT"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getResultTile("Total Questions", totalQuestions.toString(),
                    CustomStyle.primaryColor),
                getResultTile("Correct Responses", correctAnswers.toString(),
                    Colors.green),
                getResultTile("Incorrect Responses",
                    incorrectAnswers.toString(), CustomStyle.errorColor),
                getResultTile("Not Attempted", notAttempted.toString(),
                    CustomStyle.primaryColor),
              ],
            ),
          ),
        ),
        onWillPop: backCommand);
  }
}
