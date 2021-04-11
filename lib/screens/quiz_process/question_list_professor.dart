import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../services/database_services.dart';
import '../../styles.dart';
import '../subjects/subject_tile_shimmer.dart';
import 'question_card_professor.dart';
import 'question_model.dart';

class QuestionListProfessor extends StatefulWidget {
  static const routeName = "/question_list_screen";

  final String quizId;
  final String title;
  QuestionListProfessor(this.quizId, this.title);
  @override
  _QuestionListProfessorState createState() => _QuestionListProfessorState();
}

class _QuestionListProfessorState extends State<QuestionListProfessor> {
  PageController pageController;
  int currentPage;

  DatabaseServices dbs = new DatabaseServices();
  QuerySnapshot questionSnap;

  AppLifecycleState _notification;

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    pageController = PageController();
    currentPage = 0;
    dbs.getQuestionList(widget.quizId).then((value) {
      setState(() {
        questionSnap = value;
      });
    });
    super.initState();
  }

  QuestionModel snapToModel(DocumentSnapshot querySnap) {
    QuestionModel questionModel = new QuestionModel();
    questionModel.question = querySnap.data()["question"];
    questionModel.correctOption = querySnap.data()["correctOption"];

    List<String> options = [
      querySnap.data()["option1"],
      querySnap.data()["option2"],
      querySnap.data()["option3"],
      querySnap.data()["option4"]
    ];

    //options.shuffle();
    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];

    return questionModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false, //for removing back button
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text("Quiz: ${widget.title}")),
      ),
      body: Container(
          child: questionSnap == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SubjectShimmerTile(),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: questionSnap.docs.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: GestureDetector(
                                onTap: () {
                                  pageController.animateToPage(index,
                                      duration: Duration(milliseconds: 400),
                                      curve: Curves.easeIn);
                                  setState(() {
                                    currentPage = index;
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: CustomStyle.primaryColor,
                                  radius: currentPage == index ? 35 : 26,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      fontSize: currentPage == index ? 20 : 16,
                                      fontWeight: currentPage == index
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: currentPage == index
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: PageView.builder(
                            controller: pageController,
                            onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: questionSnap.docs.length,
                            itemBuilder: (context, index) {
                              return QuestionCardProfessor(
                                snapToModel(questionSnap.docs[index]),
                                index,
                              );
                            }),
                      ),
                    ),
                  ],
                )),
    );
  }
}
