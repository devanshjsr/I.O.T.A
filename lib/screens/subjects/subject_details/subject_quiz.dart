import 'package:flutter/material.dart';

import '../../../models/shared_preferences.dart';
import '../../../models/subject_model.dart';
import '../../quiz_process/attempted_quizzes.dart';
import '../../quiz_process/create_quiz.dart';
import '../../quiz_process/quiz_list_professor.dart';
import '../../quiz_process/show_quizzes.dart';

class SubjectQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (MySharedPreferences.isStudent)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowQuizzes(subject.id)));
              },
              icon: Icon(Icons.dashboard_customize),
              label: Text("Attempt Quiz"),
            ),
          if (!MySharedPreferences.isStudent)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateQuiz(subject.id)));
              },
              icon: Icon(Icons.add),
              label: Text("Create Quiz"),
            ),
          if (!MySharedPreferences.isStudent)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuizListProfessor(subject.id)));
              },
              icon: Icon(Icons.view_agenda),
              label: Text("View Quizzes"),
            ),
          if (MySharedPreferences.isStudent)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AttemptedQuizzes(subject.id)));
              },
              icon: Icon(Icons.add),
              label: Text("Attempted Quizzes"),
            ),
        ],
      ),
    );
  }
}
