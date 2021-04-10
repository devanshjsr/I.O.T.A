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

    option1Selected = false;
    option2Selected = false;
    option3Selected = false;
    option4Selected = false;

    String ans = questionModel.correctOption.split(" ")[1];
    switch (int.parse(ans)) {
      case (1):
        setState(() {
          option1Selected = true;
          option2Selected = false;
          option3Selected = false;
          option4Selected = false;
        });
        break;
      case (2):
        setState(() {
          option1Selected = false;
          option2Selected = true;
          option3Selected = false;
          option4Selected = false;
        });
        break;
      case (3):
        setState(() {
          option1Selected = false;
          option2Selected = false;
          option3Selected = true;
          option4Selected = false;
        });
        break;
      case (4):
        setState(() {
          option1Selected = false;
          option2Selected = false;
          option3Selected = false;
          option4Selected = true;
        });
        break;
      default:
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget getAnswerCard(bool isSelected, String text, int index) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: double.infinity,
        child: OutlinedButton(
          style: ElevatedButton.styleFrom(
            primary: isSelected ? Colors.green : Colors.white,
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
                    getAnswerCard(option1Selected, questionModel.option1, 1),
                    getAnswerCard(option2Selected, questionModel.option2, 2),
                    getAnswerCard(option3Selected, questionModel.option3, 3),
                    getAnswerCard(option4Selected, questionModel.option4, 4),
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
