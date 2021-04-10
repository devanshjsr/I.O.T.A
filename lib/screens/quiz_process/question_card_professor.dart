import 'package:flutter/material.dart';

import '../../styles.dart';
import 'question_model.dart';

class QuestionCardProfessor extends StatefulWidget {
  final QuestionModel questionModel;
  final int questionNumber;

  QuestionCardProfessor(
    this.questionModel,
    this.questionNumber,
  );
  // QuestionCardProfessor({Key key}) : super(key: key);
  @override
  _QuestionCardProfessorState createState() =>
      _QuestionCardProfessorState(questionModel, questionNumber);
}

class _QuestionCardProfessorState extends State<QuestionCardProfessor>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  QuestionModel questionModel;
  int questionNumber;

  _QuestionCardProfessorState(
    this.questionModel,
    this.questionNumber,
  );

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
    Widget getAnswerCard(String text) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: double.infinity,
        child: OutlinedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            side: BorderSide(width: 2, color: Colors.grey),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {},
          child: Text(
            text,
            style: TextStyle(
                color: CustomStyle.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    super.build(context);
    bool inputAllowed = true;

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
                  color: inputAllowed
                      ? CustomStyle.primaryColor
                      : Colors.green[800],
                ),
              ),
              color: inputAllowed ? Colors.white : Colors.green[50],
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
                    getAnswerCard(questionModel.option1),
                    getAnswerCard(questionModel.option2),
                    getAnswerCard(questionModel.option3),
                    getAnswerCard(questionModel.option4),
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
