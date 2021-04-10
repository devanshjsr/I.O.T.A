import 'package:iota/screens/quiz_process/question_list_professor.dart';
import 'package:iota/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      };
      quizInfo.add(quizData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        return Quiz(
                          title: quizInfo[index]["title"],
                          duration: quizInfo[index]["duration"],
                          quizId: quizInfo[index]["quizId"],
                        );
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
  final String title, duration, quizId;

  Quiz({@required this.title, @required this.duration, @required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: GestureDetector(
          child: Card(
            child: Column(
              children: [
                Text("Title - " + title),
                Text("Duration - " + duration + " minutes"),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QuestionListProfessor(this.quizId, this.title)));
          },
        ));
  }
}
