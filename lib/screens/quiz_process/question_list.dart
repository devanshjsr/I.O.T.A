import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../services/database_services.dart';
import '../../styles.dart';
import '../subjects/subject_tile_shimmer.dart';
import 'question_card.dart';
import 'question_model.dart';
import 'result_display.dart';

class QuestionList extends StatefulWidget {
  static const routeName = "/question_list_screen";

  final String quizId;
  final String startTime;
  final String endTime;
  final String title;
  QuestionList(this.quizId, this.startTime, this.endTime, this.title);
  @override
  _QuestionListState createState() => _QuestionListState(startTime, endTime);
}

class _QuestionListState extends State<QuestionList>
    with WidgetsBindingObserver {
  Timer _timer;
  int secCounter;
  int minCounter;

  int _tabswitch;
  double duration;
  PageController pageController;
  int currentPage;

  _QuestionListState(this.startTime, this.endTime);
  final String startTime, endTime;

  DatabaseServices dbs = new DatabaseServices();
  List<String> answerList;
  List<bool> markedForReview;
  QuerySnapshot questionSnap;

  AppLifecycleState _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    saveQuizInDB(answerList, questionSnap);

    _notification = state;
    //print(_notification.index);

    print(_tabswitch);
    if (_notification.index == 2) {
      _tabswitch++;
    }

    if (_tabswitch == 1 && _notification.index == 0) {
      showTabWarning();
    }

    if (_tabswitch == 2) {
      timeout();
    }
  }

  Future<dynamic> showTabWarning() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "WARNING!",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        titleTextStyle: TextStyle(color: Colors.red),
        content: Text(
            "If again a tab switch is detected quiz would be auto submitted"),
        contentTextStyle: TextStyle(color: Colors.blueGrey),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Ok"))
        ],
      ),
    );
  }

  @override
  void dispose() {
    //saveQuizInDB(answerList, questionSnap);
    //_tabswitch++;
    backWarning();
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this); //built in
    super.dispose();
    print("dis");
    pageController.dispose();
  }

  Future<dynamic> backWarning() {}

  @override
  void initState() {
    _tabswitch = 0;
    pageController = PageController();
    currentPage = 0;
    duration = DateTime.parse(widget.endTime)
        .difference(DateTime.parse(widget.startTime))
        .inSeconds
        ?.toDouble();
    dbs.getQuestionList(widget.quizId).then((value) {
      setState(() {
        questionSnap = value;
        answerList = []..length = questionSnap.docs.length;
        markedForReview = []..length = questionSnap.docs.length;
        //markedForReview.fillRange(0, questionSnap.docs.length - 1);
        //print(markedForReview);
        for (int i = 0; i < markedForReview.length; i++) {
          markedForReview[i] = false;
        }
        setTimer();
      });
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //print("init");
  }

  setTimer() {
    String currTime = DateTime.now().toIso8601String();

    int endHour = int.parse(endTime.substring(11, 13));
    int endMin = int.parse(endTime.substring(14, 16));
    int endSec = int.parse(endTime.substring(17, 19));

    int currHour = int.parse(currTime.substring(11, 13));
    int currtMin = int.parse(currTime.substring(14, 16));
    int currSec = int.parse(currTime.substring(17, 19));

    int durHour = endHour - currHour;
    int durMin = endMin - currtMin;
    int durSec = endSec - currSec;

    if (durSec < 0) {
      durSec += 60;
      durMin--;
    }
    if (durMin < 0) {
      durMin += 60;
      durHour--;
    }
    if (durHour > 0) {
      durMin += durHour * 60;
    }

    secCounter = durSec;
    minCounter = durMin;

    _timer = Timer.periodic(Duration(seconds: 1), (_timer) {
      setState(() {
        if (secCounter > 0) {
          secCounter--;
        } else if (minCounter > 0) {
          minCounter--;
          secCounter += 59;
        } else {
          timeout();
        }
      });
    });
  }

  void timeout() {
    saveQuizInDB(answerList, questionSnap);

    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ResultDisplay(answerList, questionSnap)));
  }

  void saveQuizInDB(List<String> answerList, QuerySnapshot questionSnap) async {
    Map<String, String> quizMap = {"quizId": widget.quizId};
    dbs.saveQuiz(quizMap, widget.quizId);

    for (int i = 0; i < questionSnap.docs.length; i++) {
      DocumentSnapshot currentQuestion = questionSnap.docs[i];

      Map<String, String> questionMap = {
        "question": currentQuestion.data()["question"],
        "option1": currentQuestion.data()["option1"],
        "option2": currentQuestion.data()["option2"],
        "option3": currentQuestion.data()["option3"],
        "option4": currentQuestion.data()["option4"],
        "correctOption": currentQuestion.data()["correctOption"],
        "selectedOption": answerList[i],
      };

      String questionId = widget.quizId + i.toString();
      await dbs.saveQuestion(questionMap, widget.quizId, questionId);
    }
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

    options.shuffle();
    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];

    return questionModel;
  }

  Future<bool> backCommand() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Attention!",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        titleTextStyle: TextStyle(color: Colors.red),
        content: Text("Once left you can't re-attempt the quiz"),
        contentTextStyle: TextStyle(color: Colors.blueGrey),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                timeout();
              },
              child: Text("Submit")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //print(markedForReview);
    //print(answerList);
    Future getQuestionsGrid() {
      return showDialog(
          context: context,
          builder: (ctx) {
            return Dialog(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    minHeight: 10,
                    maxWidth: 300,
                    minWidth: 10,
                  ),
                  child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1,
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: questionSnap.docs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              pageController.animateToPage(index,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeIn);
                              setState(() {
                                currentPage = index;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor:
                                  answerList[index] == null ////yahn se color
                                      ? markedForReview[index] == true
                                          ? Colors.orangeAccent
                                          : CustomStyle.primaryColor
                                      : markedForReview[index] == true
                                          ? Colors.deepPurple
                                          : Colors.green,
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
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
              ),
            );
          });
    }

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            automaticallyImplyLeading: false, //for removing back button
            title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text("Quiz: ${widget.title}")),
            actions: [
              Stack(
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      minCounter == null ? "..." : "$minCounter : $secCounter",
                      style: TextStyle(
                        color: CustomStyle.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          CustomStyle.primaryColor),
                      strokeWidth: 6,
                      backgroundColor: CustomStyle.errorColor,
                      value: minCounter == null
                          ? 1
                          : ((minCounter * 60) + secCounter) / duration,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 16),
                child: IconButton(
                  onPressed: () {
                    getQuestionsGrid();
                  },
                  icon: Icon(
                    Icons.list,
                    size: 40,
                  ),
                ),
              ),
            ],
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
                                      backgroundColor: answerList[index] ==
                                              null ////yahn se color
                                          ? markedForReview[index] == true
                                              ? Colors.orangeAccent
                                              : CustomStyle.primaryColor
                                          : markedForReview[index] == true
                                              ? Colors.deepPurple
                                              : Colors.green,
                                      radius: currentPage == index ? 35 : 26,
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize:
                                              currentPage == index ? 20 : 16,
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
                                  return QuestionCard(
                                      snapToModel(questionSnap.docs[index]),
                                      index,
                                      answerList,
                                      markedForReview);
                                }),
                          ),
                        ),
                        Container(
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
                              saveQuizInDB(answerList, questionSnap);
                              return showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    "Attention!",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  titleTextStyle: TextStyle(color: Colors.red),
                                  content: Text(
                                      "Once submitted you can't re-attempt the quiz"),
                                  contentTextStyle:
                                      TextStyle(color: Colors.blueGrey),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          timeout();
                                        },
                                        child: Text("Submit"))
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    )),
        ),
        onWillPop: backCommand);
  }
}
