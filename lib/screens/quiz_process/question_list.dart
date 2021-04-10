import 'package:flutter/material.dart';

class QuestionList extends StatefulWidget {
  static const routeName = "/question_list_screen";

  final String quizId;
  final String startTime;
  final String endTime;
  final String title;
  QuestionList(this.quizId, this.startTime, this.endTime, this.title);
  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
