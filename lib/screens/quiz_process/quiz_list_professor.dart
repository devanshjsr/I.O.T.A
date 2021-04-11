import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/database_services.dart';
import '../../styles.dart';
import 'question_list_professor.dart';

class QuizListProfessor extends StatefulWidget {
  final String subjectId;
  QuizListProfessor(this.subjectId);
  @override
  _QuizListProfessorState createState() => _QuizListProfessorState();
}

class _QuizListProfessorState extends State<QuizListProfessor> {
  DatabaseServices dbs = new DatabaseServices();
  List<DocumentSnapshot> subjectQuizList;
  List<Map<String, String>> quizInfo = [];

  Future getSubjectQuizList() async {
    subjectQuizList = await dbs.getSubjectQuizzes(widget.subjectId);
    for (int i = 0; i < subjectQuizList.length; i++) {
      DocumentSnapshot value = subjectQuizList[i];
      Map<String, String> quizData = {
        "title": value.data()["title"],
        "duration": value.data()["durationInMins"],
        "quizId": value.data()["quizId"],
        "subjectId": value.data()["subjectId"],
        "totalQuestions": value.data()["totalQuestions"],
        "dateTime": value.data()["dateTime"],
      };
      quizInfo.add(quizData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quizzes"),
        ),
        body: FutureBuilder(
          future: getSubjectQuizList(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: subjectQuizList.length,
                          itemBuilder: (context, index) {
                            // print(quizInfo[index]);
                            // print(quizInfo[index]["dateTime"].toString());
                            return Quiz(
                              title: quizInfo[index]["title"],
                              duration: quizInfo[index]["duration"],
                              quizId: quizInfo[index]["quizId"],
                              startTime: quizInfo[index]["dateTime"],
                              totalQuestions: quizInfo[index]["totalQuestions"],
                            );
                            //return Container();
                          }),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class Quiz extends StatelessWidget {
  final String title, duration, quizId, startTime, totalQuestions;

  Quiz({
    @required this.title,
    @required this.duration,
    @required this.quizId,
    this.startTime,
    this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: CustomStyle.quizTileStyle(),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QuestionListProfessor(this.quizId, this.title)));
          },
          leading: CircleAvatar(
            radius: 35,
            backgroundColor: CustomStyle.secondaryColor,
            child: CircleAvatar(
              backgroundColor: CustomStyle.primaryColor,
              radius: 25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "min",
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          title: Text(
            title,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 15, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quiz Time: ${DateFormat("dd MMM yyyy, HH:mm").format(DateTime.parse(startTime))} ",
                  style: CustomStyle.customButtonTextStyle(size: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Total Questions: $totalQuestions",
                  style: CustomStyle.customButtonTextStyle(size: 14),
                ),
              ],
            ),
          )),
    );
  }
}
