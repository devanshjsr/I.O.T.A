import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../models/data_model.dart';
import '../../models/fcm_provider.dart';
import '../../services/database_services.dart';
import '../../styles.dart';
import '../../widgets/voice_search_bottom_sheet.dart';
import '../professor/professor_main_screen.dart';

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
    await Provider.of<FcmProvider>(context, listen: false)
        .sendUpcomingTestNotification(quizMap["subjectId"], quizMap["title"],
            DateTime.now(), quizMap["durationInMins"]);
    setState(() {
      _loadingIndicator = true;
    });
    dbs.addQuiz(quizMap, _quizId);
    for (MapEntry<String, Map<String, String>> e in questionList.entries) {
      String queNo = e.key;
      String queId = _quizId + queNo;
      await dbs.addQuestion(e.value, _quizId, queId);
    }

    await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(quizMap["subjectId"])
        .collection("QuizList")
        .doc(quizMap["quizId"])
        .set({"title": quizMap["title"]});
    setState(() {
      _loadingIndicator = false;
    });

    Navigator.pushNamed(context, ProfessorMainScreen.routeName);
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
  TextEditingController controller;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    controller = TextEditingController();
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    addQuestionDataFromVoice(String data) {
      controller.text += data;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          width: 3,
          color: inputAllowed ? CustomStyle.primaryColor : Colors.green[800],
        ),
      ),
      color: inputAllowed ? Colors.white : Colors.green[50],
      elevation: 5,
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Question ${questionNumber + 1}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CustomStyle.primaryColor,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                maxLines: 5,
                minLines: 3,
                controller: controller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: CustomStyle.customTextFieldDecoration(
                  labelText: 'Question',
                  suffixIconBtn: IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (_) {
                          return VoiceSearchBottomSheet(
                              addQuestionDataFromVoice);
                        },
                      );
                    },
                  ),
                ),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value.length == 0) {
                    return DataModel.REQUIRED;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => question = value,
                enabled: inputAllowed,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: CustomStyle.customTextFieldDecoration(
                  labelText: 'Option 1',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.length == 0) {
                    return DataModel.REQUIRED;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => option1 = value,
                enabled: inputAllowed,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: CustomStyle.customTextFieldDecoration(
                  labelText: 'Option 2',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.length == 0) {
                    return DataModel.REQUIRED;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => option2 = value,
                enabled: inputAllowed,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: CustomStyle.customTextFieldDecoration(
                  labelText: 'Option 3',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.length == 0) {
                    return DataModel.REQUIRED;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => option3 = value,
                enabled: inputAllowed,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: CustomStyle.customTextFieldDecoration(
                  labelText: 'Option 4',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.length == 0) {
                    return DataModel.REQUIRED;
                  } else {
                    return null;
                  }
                },
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(FocusNode()),
                onSaved: (value) => option4 = value,
                enabled: inputAllowed,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Correct Option: ",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CustomStyle.primaryColor),
                  ),
                  DropdownButton<String>(
                      value: dropDownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      elevation: 16,
                      style: const TextStyle(
                          color: CustomStyle.primaryColor, fontSize: 14),
                      onChanged: !inputAllowed
                          ? null
                          : (newValue) {
                              setState(() {
                                dropDownValue = newValue;
                                correctOption = newValue;
                              });
                            },
                      items: <String>[
                        'Option 1',
                        'Option 2',
                        'Option 3',
                        'Option 4',
                      ].map<DropdownMenuItem<String>>(
                        (String value) {
                          //correctOption = value;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: CustomStyle.customElevatedButtonStyle(),
                    onPressed: add,
                    child: Text(
                      "Save",
                      style: CustomStyle.customButtonTextStyle(
                        color: CustomStyle.textLight,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: CustomStyle.customElevatedButtonStyle(),
                    onPressed: edit,
                    child: Text(
                      "Edit",
                      style: CustomStyle.customButtonTextStyle(
                        color: CustomStyle.textLight,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
