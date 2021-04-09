import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/data_model.dart';
import '../../services/database_services.dart';
import '../../styles.dart';
import '../temp_screen.dart';

String _quizId;
int _totalQuestions;
List<bool> isIncomplete;
Map<String, Map<String, String>> questionList = new Map();
bool isOkay = true;
DatabaseServices dbs = new DatabaseServices();
Map<String, String> quizMap;

class AddQuestions extends StatefulWidget {
  static const routeName = "/add_question_screen";

  @override
  _AddQuestionsState createState() => _AddQuestionsState();

  AddQuestions(var dataMap) {
    quizMap = new Map();

    quizMap.addAll(dataMap);
    _totalQuestions = int.parse(quizMap["totalQuestions"]);
    _quizId = quizMap["quizId"];
    isIncomplete = []..length = _totalQuestions;
  }
}

String question, option1, option2, option3, option4, correctOption = "Option 1";

class _AddQuestionsState extends State<AddQuestions> {
  bool _loadingIndicator;
  List<Map<String, String>> dataMap = [];
  List<GlobalKey<FormState>> keyList = [];
  @override
  void initState() {
    _loadingIndicator = false;
    // TODO: implement initState
    isOkay = true;
    for (int i = 0; i < isIncomplete.length; i++) {
      isIncomplete[i] = true;
    }
    super.initState();
  }
  // getInstance() {
  //   return object;
  // }

  void submit() async {
    setState(() {
      _loadingIndicator = true;
    });
    dbs.addQuiz(quizMap, _quizId);
    for (MapEntry<String, Map<String, String>> e in questionList.entries) {
      String queNo = e.key;
      String queId = _quizId + queNo;
      await dbs.addQuestion(e.value, _quizId, queId);
    }
    setState(() {
      _loadingIndicator = false;
    });

    Navigator.pushNamed(context, Temp.routeName);
  }

  //  Using listView.builder to generate (totalQuestions+1) widgets
  //  One extra for SUBMIT button
  @override
  Widget build(BuildContext context) {
    // quizMap = new Map();
    // quizMap = ModalRoute.of(context).settings.arguments; //error due to this let it be constructor

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Quiz"),
      ),
      backgroundColor: Colors.white,
      body: _loadingIndicator
          ? Container(
              child: Center(
              child: CircularProgressIndicator(),
            ))
          : Column(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        addAutomaticKeepAlives: true,
                        itemCount: _totalQuestions + 1,
                        itemBuilder: (context, index) {
                          if (index != _totalQuestions) {
                            return QuestionInfo(
                              questionNumber: index,
                            );
                          } else {
                            return Container(
                              width: double.infinity,
                              height: 50,
                              color: CustomStyle.primaryColor,
                              child: InkWell(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Submit",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.customButtonTextStyle(
                                        color: CustomStyle.textLight,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  for (int i = 0;
                                      i < isIncomplete.length;
                                      i++) {
                                    if (isIncomplete[i] == true) {
                                      print(i);
                                      isOkay = false;
                                      return showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            "One or more questions Unsaved!",
                                            style: CustomStyle
                                                .customButtonTextStyle(),
                                          ),
                                          titleTextStyle:
                                              TextStyle(color: Colors.red),
                                          content: Text("Save all then Submit"),
                                          contentTextStyle:
                                              TextStyle(color: Colors.blueGrey),
                                          actions: [
                                            OutlinedButton(
                                                style: CustomStyle
                                                    .customElevatedButtonStyle(),
                                                onPressed: () {
                                                  setState(() {
                                                    isOkay = true;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "Ok",
                                                  style: CustomStyle
                                                      .customButtonTextStyle(
                                                    color:
                                                        CustomStyle.textLight,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      );
                                      // break;
                                    }
                                  }
                                  isOkay
                                      ? submit()
                                      : Navigator.of(context).pop();
                                },
                              ),
                            );
                          }
                        }),
                  ),
                ),
              ],
            ),
    );
  }
}

class QuestionInfo extends StatefulWidget {
  final questionNumber;
  QuestionInfo({this.questionNumber});
  @override
  _QuestionInfoState createState() => _QuestionInfoState(questionNumber);
}

class _QuestionInfoState extends State<QuestionInfo>
    with AutomaticKeepAliveClientMixin {
  final int questionNumber;
  bool inputAllowed = true;
  String dropDownValue = "Option 1";

  _QuestionInfoState(this.questionNumber);
  // bool _loadingIndicator2 = false;

  //AddQuestions object = new AddQuestions();
  final _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  void initState() {
    isIncomplete[questionNumber] = inputAllowed;
    super.initState();
  }

  void add() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        // _loadingIndicator2 = true;
        inputAllowed = false;
        isIncomplete[questionNumber] = inputAllowed;
      });

      Map<String, String> dataMap = {
        "question": question,
        "option1": option1,
        "option2": option2,
        "option3": option3,
        "option4": option4,
        "correctOption": correctOption,
      };

      // String queId = _quizId + questionNumber.toString();
      questionList.putIfAbsent(questionNumber.toString(), () => null);
      questionList.update(questionNumber.toString(), (value) => dataMap);

      setState(() {
        question = null;
        option1 = null;
        option2 = null;
        option3 = null;
        option4 = null;
        correctOption = "Option 1";
        // _loadingIndicator2 = false;
      });

      // await dbs.addQuestion(dataMap, _quizId, queId).then((value) {});
    }
  }

  void edit() {
    setState(() {
      inputAllowed = true;
      isIncomplete[questionNumber] = inputAllowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold()
    
  }
}
