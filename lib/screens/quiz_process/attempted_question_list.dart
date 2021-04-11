import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../services/database_services.dart';
import 'attempted_question_card.dart';
import 'question_model.dart';

class AttemptedQuestionList extends StatefulWidget {
  static const routeName = "/attempted_question_list_screen";

  final String quizId;
  final String quizName;
  AttemptedQuestionList(this.quizId, this.quizName);
  @override
  _AttemptedQuestionListState createState() =>
      _AttemptedQuestionListState(quizId);
}

class _AttemptedQuestionListState extends State<AttemptedQuestionList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  _AttemptedQuestionListState(this.quizId);
  final String quizId;
  DatabaseServices dbs = new DatabaseServices();
  QuerySnapshot _questionSnap;

  @override
  void initState() {
    //print("kkk");
    //print(quizId);

    super.initState();
  }

  Future future() async {
    QuerySnapshot value = await dbs.getAttemptedQuestionList(quizId);
    _questionSnap = value;
  }

  QuestionModel snapToModel(DocumentSnapshot querySnap) {
    QuestionModel questionModel = new QuestionModel();
    questionModel.question = querySnap.data()["question"];
    questionModel.correctOption = querySnap.data()["correctOption"];
    questionModel.selectedOption = querySnap.data()["selectedOption"];

    questionModel.option1 = querySnap.data()["option1"];
    questionModel.option2 = querySnap.data()["option2"];
    questionModel.option3 = querySnap.data()["option3"];
    questionModel.option4 = querySnap.data()["option4"];
    return questionModel;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Quiz: ${widget.quizName}"),
        ),
        body: FutureBuilder(
            future: future(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        child: new ListView.builder(
                            itemCount: _questionSnap.docs.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: dbs.getAttemptedQuesInfo(
                                      quizId, quizId + index.toString()),
                                  builder: (ctx, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return AttemptedQuestionCard(
                                          snapToModel(snapshot.data), index);
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  });
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
            }));
  }
}
