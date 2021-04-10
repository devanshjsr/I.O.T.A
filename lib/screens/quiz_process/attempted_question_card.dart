import 'package:flutter/material.dart';

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      elevation: 7,
      child: Column(
        children: [
          Container(
            child: Text("Q " +
                (questionNumber + 1).toString() +
                " " +
                questionModel.question),
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            child: Text(questionModel.option1),
            color: (_correctOption == "option1")
                ? Colors.green
                : option1Selected
                    ? Colors.red[800]
                    : Colors.grey[100],
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            child: Text(questionModel.option2),
            color: (_correctOption == "option2")
                ? Colors.green
                : option2Selected
                    ? Colors.red[800]
                    : Colors.grey[100],
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            child: Text(questionModel.option3),
            color: (_correctOption == "option3")
                ? Colors.green
                : option3Selected
                    ? Colors.red[800]
                    : Colors.grey[100],
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            child: Text(questionModel.option4),
            color: (_correctOption == "option4")
                ? Colors.green
                : option4Selected
                    ? Colors.red[800]
                    : Colors.grey[100],
          ),
        ],
      ),
    );
  }
}
