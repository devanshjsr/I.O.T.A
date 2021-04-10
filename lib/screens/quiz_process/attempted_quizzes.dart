import 'package:iota/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iota/screens/quiz_process/attempted_question_list.dart';

class AttemptedQuizzes extends StatefulWidget {
  final String subjectId;
  AttemptedQuizzes(this.subjectId);
  @override
  _AttemptedQuizzesState createState() => _AttemptedQuizzesState();
}

class _AttemptedQuizzesState extends State<AttemptedQuizzes> {
  DatabaseServices dbs = new DatabaseServices();
  QuerySnapshot quizListSnap;
  //DocumentSnapshot quizInfo;
  List<Map<String, String>> quizInfo = [];

  Future getAttemptedQuizList() async {
    QuerySnapshot snapshotRes = await dbs.getAttemptedQuizzes();

    quizListSnap = snapshotRes;

    print("snapshot  ${snapshotRes.docs.first.id}");

    for (int i = 0; i < quizListSnap.docs.length; i++) {
      String currentId = quizListSnap.docs[i].id;
      DocumentSnapshot value = await dbs.getAttemptedQuizData(currentId);

      print("HEREEEEEEEEEEEEEEEEEEEEE");
      Map<String, String> quizData = {
        "title": value.data()["title"],
        "duration": value.data()["durationInMins"],
        "quizId": currentId,
        "subjectId": value.data()["subjectId"],
      };
      quizInfo.add(quizData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: getAttemptedQuizList(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  child: new ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: quizListSnap.docs.length,
                      itemBuilder: (context, index) {
                        if (quizInfo[index]["subjectId"] == widget.subjectId) {
                          return FutureBuilder(
                              future: dbs.checkIfCurrentStudentAttemptedQuiz(
                                  quizInfo[index]["quizId"]),
                              builder: (ctx, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.data == true) {
                                    return Quiz(
                                      title:
                                          quizInfo[index]["title"].toString(),
                                      duration: quizInfo[index]["duration"]
                                          .toString(),
                                      quizId: quizInfo[index]["quizId"],
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              });
                        } else {
                          return Container();
                        }
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
                    builder: (context) => AttemptedQuestionList(quizId)));
          },
        ));
  }
}
