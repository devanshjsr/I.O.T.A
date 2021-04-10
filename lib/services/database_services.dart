import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  Future<void> addQuiz(Map quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addQuestion(Map queData, String quizId, String queId) async {
    await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .collection(quizId)
        .doc(queId)
        .set(queData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getQuizInfo() async {
    return FirebaseFirestore.instance.collection("Quiz_List").snapshots();
  }

  getQuestionList(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .collection(quizId)
        .get();
  }

  Future<void> saveQuiz(Map<String, String> quizMap, String quizId) async {
    await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .set(quizMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> saveQuestion(Map queData, String quizId, String queId) async {
    await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection(quizId)
        .doc(queId)
        .set(queData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getAttemptedQuizzes() async {
    return FirebaseFirestore.instance.collection("AttemptedQuiz").get();
  }

  getAttemptedQuizData(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .get();
  }

  getAttemptedQuestionList(String quizId) async {
    //print(quizId);
    return await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection(quizId)
        .get();
  }
}
