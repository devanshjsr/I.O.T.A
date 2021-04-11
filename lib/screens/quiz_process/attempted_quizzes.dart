import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/database_services.dart';
import '../../styles.dart';
import 'attempted_question_list.dart';

class AttemptedQuizzes extends StatelessWidget {
  final String subjectId;
  AttemptedQuizzes(this.subjectId);

  @override
  Widget build(BuildContext context) {
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
        print(value.data());
        Map<String, String> quizData = {
          "title": value.data()["title"],
          "duration": value.data()["durationInMins"],
          "quizId": currentId,
          "subjectId": value.data()["subjectId"],
          "startTime": value.data()["dateTime"],
          "totalQuestions": value.data()["totalQuestions"],
        };
        quizInfo.add(quizData);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Attempted Quizzes"),
        ),
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
                            if (quizInfo[index]["subjectId"] == subjectId) {
                              return FutureBuilder(
                                  future:
                                      dbs.checkIfCurrentStudentAttemptedQuiz(
                                          quizInfo[index]["quizId"]),
                                  builder: (ctx, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.data == true) {
                                        print(quizInfo[index]);
                                        return Quiz(
                                          title: quizInfo[index]["title"]
                                              .toString(),
                                          duration: quizInfo[index]["duration"]
                                              .toString(),
                                          quizId: quizInfo[index]["quizId"],
                                          startTime: quizInfo[index]
                                              ["startTime"],
                                          totalQuestions: quizInfo[index]
                                              ["totalQuestions"],
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
                builder: (context) => AttemptedQuestionList(quizId, title),
              ),
            );
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
