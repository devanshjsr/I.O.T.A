import 'package:flutter/material.dart';

import '../../styles.dart';
import 'question_model.dart';

class AttemptedQuestionCard extends StatefulWidget {
  final QuestionModel questionModel;
  final int questionNumber;

  AttemptedQuestionCard(this.questionModel, this.questionNumber);
  // AttemptedQuestionCard({Key key}) : super(key: key);
  @override
  _AttemptedQuestionCardState createState() =>
      _AttemptedQuestionCardState(this.questionModel, this.questionNumber);
}

class _AttemptedQuestionCardState extends State<AttemptedQuestionCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  QuestionModel questionModel;
  int questionNumber;

  _AttemptedQuestionCardState(this.questionModel, this.questionNumber);

  bool option1Selected,
      option2Selected,
      option3Selected,
      option4Selected,
      optionSelected;
  String _correctOption;

  @override
  void initState() {
    // TODO: implement initState

    option1Selected = false;
    option2Selected = false;
    option3Selected = false;
    option4Selected = false;
    _correctOption = (questionModel.correctOption.split(" ")[0] +
            questionModel.correctOption.split(" ")[1])
        .toLowerCase();
    String selectedOption = questionModel.selectedOption;
    print(questionModel.option1);
    print(selectedOption);

    if (selectedOption != null) {
      if (questionModel.option1.compareTo(selectedOption) == 0) {
        print("ls");
        option1Selected = true;
      } else if (questionModel.option2.compareTo(selectedOption) == 0) {
        print("2s");
        option2Selected = true;
      } else if (questionModel.option3.compareTo(selectedOption) == 0) {
        print("3s");
        option3Selected = true;
      } else if (questionModel.option4.compareTo(selectedOption) == 0) {
        print("4s");
        option4Selected = true;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget getAnswerCard(String text, String optionNumber, bool isSelected) {
      Color color = (_correctOption == optionNumber)
          ? Colors.green
          : isSelected
              ? Colors.red[800]
              : CustomStyle.primaryColor;
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: double.infinity,
        child: OutlinedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            side: BorderSide(
                width: (_correctOption == optionNumber)
                    ? 4
                    : isSelected
                        ? 4
                        : 2,
                color: color),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {},
          child: Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    bool checkIfAnsIsCorrect() {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(option1Selected);
      print(option2Selected);
      print(option3Selected);
      print(option4Selected);
      print(_correctOption);

      if (option1Selected && _correctOption == "option1")
        return true;
      else if (option2Selected && _correctOption == "option2")
        return true;
      else if (option3Selected && _correctOption == "option3")
        return true;
      else if (option4Selected && _correctOption == "option4")
        return true;
      else
        return false;
    }

    super.build(context);

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
                  color: checkIfAnsIsCorrect()
                      ? Colors.green[800]
                      : Colors.red[800],
                ),
              ),
              elevation: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        checkIfAnsIsCorrect()
                            ? Icon(
                                Icons.check,
                                color: Colors.green[800],
                              )
                            : questionModel.selectedOption != null
                                ? Icon(
                                    Icons.dangerous,
                                    color: Colors.red[800],
                                  )
                                : Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                  ),
                        Expanded(
                          child: Text(
                            questionModel.question,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CustomStyle.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          width: 24,
                        )
                      ],
                    ),
                    getAnswerCard(
                        questionModel.option1, "option1", option1Selected),
                    getAnswerCard(
                        questionModel.option2, "option2", option2Selected),
                    getAnswerCard(
                        questionModel.option3, "option3", option3Selected),
                    getAnswerCard(
                        questionModel.option4, "option4", option4Selected),
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
