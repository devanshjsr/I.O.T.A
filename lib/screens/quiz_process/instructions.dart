import 'package:flutter/material.dart';

import '../../styles.dart';
import 'question_list.dart';

class QuizInstructions extends StatelessWidget {
  final String quizId, startTime, endTime, title;
  QuizInstructions(this.title, this.startTime, this.endTime, this.quizId);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz instructions !!"),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Text(
                "Please read the following instructions carefully before beginning your quiz",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomStyle.primaryColor,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Question color scheme :",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CustomStyle.primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 50),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: CustomStyle.primaryColor,
                            child: Text(
                              "1",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        Text(
                          "Unattempted questions",
                          style: TextStyle(
                              color: CustomStyle.primaryColor, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 50),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.green,
                            child: Text(
                              "2",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        Text(
                          "Attempted questions",
                          style: TextStyle(
                              color: CustomStyle.primaryColor, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 50),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              "3",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        Text(
                          "Attempted and \nmarked for review",
                          style: TextStyle(
                              color: CustomStyle.primaryColor, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 50),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.orangeAccent,
                            child: Text(
                              "4",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        Text(
                          "Unattempted and\n marked for review",
                          style: TextStyle(
                              color: CustomStyle.primaryColor, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 15, top: 30),
                  child: Icon(
                    Icons.circle,
                    size: 14,
                  ),
                ),
                Text(
                  "Only one attempt is allowed",
                  style: TextStyle(
                      color: CustomStyle.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Icon(
                    Icons.circle,
                    size: 14,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Text(
                    "If more than one app switch is detected, the quiz will autosubmit",
                    style: TextStyle(
                        color: CustomStyle.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Icon(
                    Icons.circle,
                    size: 14,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Text(
                    "The quiz will automatically submit if you fail to submit the quiz in the given time",
                    style: TextStyle(
                        color: CustomStyle.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              QuestionList(quizId, startTime, endTime, title)));
                },
                child: Container(
                  height: 70,
                  color: Colors.blue[700],
                  alignment: Alignment.center,
                  child: Text(
                    "I AGREE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
