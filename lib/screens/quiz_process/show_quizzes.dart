import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../services/database_services.dart';
import '../../styles.dart';
import 'instructions.dart';

class ShowQuizzes extends StatefulWidget {
  final String subjectId;
  ShowQuizzes(this.subjectId);
  static const routeName = "/show_quizzes_screen";

  @override
  _ShowQuizzesState createState() => _ShowQuizzesState();
}

class _ShowQuizzesState extends State<ShowQuizzes> {
  Stream quizStream;
  DatabaseServices dbs = new DatabaseServices();

  Widget quizList() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attempt Quiz"),
      ),
      body: Container(
        child: StreamBuilder(
          stream: quizStream,
          builder: (context, snapshot) {
            return snapshot.data == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue[800],
                        ),
                      ),
                    ],
                  )
                : snapshot.data.documents.length == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "No Quizzes To Do",
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                          Center(
                              child: Text(
                            "#LiteLo",
                            style: TextStyle(color: Colors.blueGrey),
                          ))
                        ],
                      )
                    : ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          print(snapshot.data.documents.length);
                          String currentTime = DateTime.now().toIso8601String();
                          String endTime = DateTime.parse(snapshot
                                  .data.documents[index]
                                  .data()["dateTime"])
                              .add(Duration(
                                  minutes: int.parse(snapshot
                                      .data.documents[index]
                                      .data()["durationInMins"])))
                              .toIso8601String();
                          if (endTime
                                  .substring(0, 19)
                                  .compareTo(currentTime.substring(0, 19)) >
                              0) {
                            return Quiz(
                              title: snapshot.data.documents[index]
                                  .data()["title"],
                              duration: snapshot.data.documents[index]
                                  .data()["durationInMins"],
                              totalQuestions: snapshot.data.documents[index]
                                  .data()["totalQuestions"],
                              quizId: snapshot.data.documents[index]
                                  .data()["quizId"],
                              startDateTime: snapshot.data.documents[index]
                                  .data()["dateTime"],
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    dbs.getQuizInfo(widget.subjectId).then((value) {
      setState(() {
        quizStream = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: quizList(),
    );
  }
}

class Quiz extends StatelessWidget {
  final String title, duration, totalQuestions, quizId, startDateTime;
  DatabaseServices dbs = new DatabaseServices();

  Quiz(
      {@required this.title,
      @required this.duration,
      @required this.totalQuestions,
      @required this.quizId,
      @required this.startDateTime});

  @override
  Widget build(BuildContext context) {
    Widget getTile(bool isAttempted, bool isOngoing) {
      if (isAttempted) {
        //dbs.deleteAttemptedQuiz(quizId);
        return Container();
      }
      return Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: CustomStyle.quizTileStyle(isOngoing: isOngoing),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
            enabled: isOngoing,
            onTap: () {
              String currentTime = DateTime.now().toIso8601String();
              String endTime = DateTime.parse(startDateTime)
                  .add(Duration(minutes: int.parse(duration)))
                  .toIso8601String();
              String startTime = startDateTime;
              if (startTime
                          .substring(0, 19)
                          .compareTo(currentTime.substring(0, 19)) <
                      0 &&
                  endTime
                          .substring(0, 19)
                          .compareTo(currentTime.substring(0, 19)) >
                      0) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) =>
                        QuizInstructions(title, startTime, endTime, quizId)));
              } else {
                Fluttertoast.showToast(msg: "Quiz hasn't started yet");
              }
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
              style: CustomStyle.customButtonTextStyle(
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 15, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Time: ${DateFormat("dd MMM yyyy, HH:mm").format(DateTime.parse(startDateTime))} ",
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

    Future<bool> checkIfAttempted() async {
      var res = await FirebaseFirestore.instance
          .collection("AttemptedQuiz")
          .doc(quizId)
          .collection("StudentResponses")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get();
      if (res.exists == true) {
        return true;
      } else {
        return false;
      }
    }

    String currentTime = DateTime.now().toIso8601String();
    String endTime = DateTime.parse(startDateTime)
        .add(Duration(minutes: int.parse(duration)))
        .toIso8601String();
    bool isOngoing =
        endTime.substring(0, 19).compareTo(currentTime.substring(0, 19)) > 0;
    return FutureBuilder(
      future: checkIfAttempted(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return getTile(snapshot.data, isOngoing);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
