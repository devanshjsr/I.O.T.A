import 'package:flutter/material.dart';

import '../../styles.dart';
import 'question_model.dart';

class QuestionCard extends StatefulWidget {
  final QuestionModel questionModel;
  final int questionNumber;
  final List<String> answerList;
  final List<bool> markedForReview;

  QuestionCard(this.questionModel, this.questionNumber, this.answerList,
      this.markedForReview);
  // QuestionCard({Key key}) : super(key: key);
  @override
  _QuestionCardState createState() => _QuestionCardState(
      questionModel, questionNumber, answerList, markedForReview);
}

class _QuestionCardState extends State<QuestionCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  QuestionModel questionModel;
  int questionNumber;
  List<String> answerList;
  List<bool> markedForReview;

  _QuestionCardState(this.questionModel, this.questionNumber, this.answerList,
      this.markedForReview);

  bool option1Selected,
      option2Selected,
      option3Selected,
      option4Selected,
      optionSelected;

  @override
  void initState() {
    // TODO: implement initState

    option1Selected = false;
    option2Selected = false;
    option3Selected = false;
    option4Selected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget getAnswerCard(bool isSelected, Function onPressed, String text) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: double.infinity,
        child: OutlinedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            side: BorderSide(
                width: isSelected ? 4 : 2,
                color: isSelected ? Colors.green : Colors.grey),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            onPressed();
          },
          child: Text(
            text,
            style: TextStyle(
                color: isSelected ? Colors.green : CustomStyle.primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    super.build(context);
    print(answerList);
    print(markedForReview);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  width: 3,
                  color: CustomStyle.primaryColor,
                ),
              ),
              color: Colors.white,
              elevation: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      questionModel.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CustomStyle.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    getAnswerCard(option1Selected, () {
                      setState(() {
                        option1Selected = true;
                        option2Selected = false;
                        option3Selected = false;
                        option4Selected = false;
                        answerList[questionNumber] = questionModel.option1;
                      });
                    }, questionModel.option1),
                    getAnswerCard(option2Selected, () {
                      setState(() {
                        option1Selected = false;
                        option2Selected = true;
                        option3Selected = false;
                        option4Selected = false;
                        answerList[questionNumber] = questionModel.option2;
                      });
                    }, questionModel.option2),
                    getAnswerCard(option3Selected, () {
                      setState(() {
                        option1Selected = false;
                        option2Selected = false;
                        option3Selected = true;
                        option4Selected = false;
                        answerList[questionNumber] = questionModel.option3;
                      });
                    }, questionModel.option3),
                    getAnswerCard(option4Selected, () {
                      setState(() {
                        option1Selected = false;
                        option2Selected = false;
                        option3Selected = false;
                        option4Selected = true;
                        answerList[questionNumber] = questionModel.option4;
                      });
                    }, questionModel.option4),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          side: BorderSide(
                              width: 3, color: CustomStyle.errorColor),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            option1Selected = false;
                            option2Selected = false;
                            option3Selected = false;
                            option4Selected = false;
                            answerList[questionNumber] = null;
                          });
                        },
                        child: Text(
                          "Clear Selection",
                          style: TextStyle(
                            color: CustomStyle.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          side: BorderSide(
                              width: 3, color: CustomStyle.primaryColor),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            markedForReview[questionNumber] = true;
                          });
                        },
                        child: Text(
                          "Mark for Review",
                          style: TextStyle(
                            color: CustomStyle.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          side: BorderSide(
                              width: 3, color: CustomStyle.primaryColor),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            markedForReview[questionNumber] = false;
                          });
                        },
                        child: Text(
                          "Unmark",
                          style: TextStyle(
                            color: CustomStyle.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
