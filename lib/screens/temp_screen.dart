//import 'package:QuizApp/screens/quiz_process/attempted_quizzes.dart';

import 'quiz_process/create_quiz.dart';
import 'quiz_process/show_quizzes.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter/material.dart';

//  temporary screen to access quiz section
//  Remove later on after completion of functionality

class Temp extends StatelessWidget {
  static const routeName = "/temp_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temp"),
      ),
      drawer: AppDrawer("Temp"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShowQuizzes()));
              },
              icon: Icon(Icons.dashboard_customize),
              label: Text("Attempt Quiz"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateQuiz()));
              },
              icon: Icon(Icons.add),
              label: Text("Create Quiz"),
            ),
                      ],
        ),
      ),
    );
  }
}
