import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fcm_provider.dart';
import '../widgets/app_drawer.dart';
import 'quiz_process/attempted_quizzes.dart';
import 'quiz_process/create_quiz.dart';
import 'quiz_process/show_quizzes.dart';

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
                    MaterialPageRoute(builder: (context) => ShowQuizzes("aa")));
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
                    MaterialPageRoute(builder: (context) => CreateQuiz("AA")));
              },
              icon: Icon(Icons.add),
              label: Text("Create Quiz"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AttemptedQuizzes("AA")));
              },
              icon: Icon(Icons.add),
              label: Text("Attempted Quizzes"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
              ),
              onPressed: () {
                Provider.of<FcmProvider>(context, listen: false)
                    .sendUpcomingTestNotification(
                        "00eAKQudZE2e9vXB531D", "Demo", DateTime.now(), "10");
              },
              icon: Icon(Icons.add),
              label: Text("FCM"),
            ),
          ],
        ),
      ),
    );
  }
}
